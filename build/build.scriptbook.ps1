param(
    $Actions,
    [bool]$Publish = $false
)

if (!(Get-Module Scriptbook -ErrorAction Ignore))
{
    Throw "Scriptbook Module not installed. Use command 'Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser' or use ./build.ps1"
}

$PSModule = 'Scriptbook'
$PSModuleVersion = $null
$OutputDir = "../deploy/Output"

Write-Info "Build Script"
Write-Info ""
Write-Info "Parameters"
Write-Info "              Action: $Actions"
Write-Info "             Publish: $Publish"
Write-Info "              Module: $PSModule"
Write-Info ""
Write-Info " Computer details"
Write-Info "      Computer: $([Environment]::MachineName)"
Write-Info "        WhoAmI: $([Environment]::UserName)"
Write-Info "    Powershell: $($PSVersionTable.PsVersion)"
Write-Info "            OS: $([Environment]::OSVersion.VersionString)"
Write-Info "          Time: $((Get-Date).ToString('s'))"
Write-Info "Current-folder: $(Get-Location)"
Write-Info ""

. ./build.helpers.ps1

Action Init {
    Get-ChildItem env:* | Sort-Object -Property Name | Out-String | Write-Info
}

Action Analyze {
    $scriptAnalysisSettingsPath = '../src/tests/ScriptAnalyzerSettings.psd1'
    $result = Invoke-ScriptAnalyzer -Path ../src/$PSModule -Settings $scriptAnalysisSettingsPath -Recurse -Verbose:$VerbosePreference
    $errors = ($result.where( { $_.Severity -eq 'Error' })).Count
    $result | Format-Table -AutoSize | Out-String | Write-Info
    if ($errors -gt 0) 
    {
        Throw "ScriptAnalyzer ($errors) errors found"
    }    
}

Action Compile {
    # clean output
    Remove-Item (Join-Path $OutputDir *) -Recurse -ErrorAction Ignore

    # determine version
    $moduleManifest = Import-PowerShellDataFile ../src/$PSModule/$PSModule.psd1
    $Script:PSModuleVersion = $moduleManifest.ModuleVersion.ToString()
    $output = Join-Path (Join-Path $OutputDir $PSModule) $moduleManifest.ModuleVersion.ToString()
    New-Item -Path $output -ItemType Directory -ErrorAction Ignore | Out-Null

    # copy manifest and module
    $psd1File = Join-Path $output "$PSModule.psd1"
    $psmFile = Join-Path $output "$PSModule.psm1"
    Copy-Item ../src/$PSModule/$PSModule.* $output

    # compose (build) module
    $dotSourceParams = @{
        Filter      = '*.ps1'
        Recurse     = $true
        ErrorAction = 'Stop'
    }
    $public = @(Get-ChildItem -Path (Join-Path -Path ../src/$PSModule -ChildPath 'Public') @dotSourceParams )
    $private = @(Get-ChildItem -Path (Join-Path -Path ../src/$PSModule -ChildPath 'Private/*.ps1') @dotSourceParams)
    $public + $private | Get-Content -Raw | Add-Content -Path ($psmFile)

    # update manifest FunctionsToExport
    Update-ModuleManifest -Path $psd1File -FunctionsToExport $public.BaseName

    Write-Info "Create module: $PSModule"
    Write-Info "Create $psd1File"
    Write-Info "Create $psmFile"
}

Action Sign -Depends Compile {
    # Windows Only
    if (!$IsWindows)
    {
        Write-Warning "No code signing on platforms other than Windows"
        return
    }

    $cert = $null

    # load cert from Agent
    if ( (!!$env:SYSTEM_TEAMPROJECT))
    {
        $certLoc = "$($env:AGENT_WORKFOLDER)/_temp/code-signing-cert.pfx"
        try
        {
            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certLoc, $env:CertPassword);
            Write-Info "Loaded signing cert";
        }
        catch
        {
            Write-Info "Unable to load certificate from '$certLoc'" + $_
        }
    }

    # load cert from store
    if ( !$cert )
    {
        $cert = Get-ChildItem -Path "Cert:\CurrentUser\My" -CodeSigningCert -ErrorAction Ignore | Where-Object { $_.Subject.StartsWith('CN=Tedon') } | Sort-Object NotAfter  | Select-Object -Last 1
    }

    if ($cert)
    {
        Get-ChildItem (Join-Path $OutputDir '.\Scriptbook.*') -Recurse | Set-AuthenticodeSignature -Certificate $cert -TimestampServer 'http://timestamp.digicert.com'
    }
    else
    {
        Write-Warning "Code not signed, cert not found"
    }
}

$Script:TestResult = $false

Action Test {
    Push-Location ../src/tests
    try
    {
        Assert-Version dotnet 3.0 -Minimum
        $loc = Get-Location
        $r = Invoke-Pester -Script $loc -PassThru -OutputFile "$loc/Test-Pester.xml" -OutputFormat 'JUnitXML' -ExcludeTagFilter 'e2e'
        Show-PesterOutput $r
        $Script:TestResult = $r.Result -eq 'Passed'
    }
    finally
    {
        Pop-Location
    }  
}

Action MakeDocs -If { $Publish } {

    $path = '../docs/Functions'
    New-Item -Path $path -ItemType Directory -Force -ErrorAction Ignore
    $map = @{}

    $dotSourceParams = @{
        Filter      = '*.ps1'
        Recurse     = $true
        ErrorAction = 'Stop'
    }
    $public = @(Get-ChildItem -Path (Join-Path -Path "../src/$PSModule" -ChildPath 'public') @dotSourceParams ) 

    $public | ForEach-Object {
        try
        {
            $func = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path -Leaf -Path $_))
            $type = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path -Leaf -Path (Split-Path -Parent -Path $_)))
            New-MarkdownHelp -Command $func -OutputFolder (Join-Path $path $type) -Force -Metadata @{ } | Out-Null
            $map[$func] = $type
        }
        catch
        {
            Write-Warning "Error generating documentation for function $func"
        }
    }

    # update docs to bind links to unlinked functions
    Get-ChildItem -Path $path -Recurse -Filter '*.md' | ForEach-Object {
        $depth = ($_.FullName.Replace($path, [string]::Empty).trim('\/') -split '[\\/]').Length

        $content = (Get-Content -Path $_.FullName | ForEach-Object {
                $line = $_
                while ($line -imatch '\[`(?<name>[a-z]+\-deploy[a-z]+)`\](?<char>[^(])')
                {
                    $name = $Matches['name']
                    $char = $Matches['char']
                    $line = ($line -ireplace "\[``$($name)``\][^(]", "[``$($name)``]($('../' * $depth)Functions/$($map[$name])/$($name))$($char)")
                }
                $line
            })

        $content | Out-File -FilePath $_.FullName -Force -Encoding ascii
    }

    if (!(Get-Command mkdocs -ErrorAction Ignore))
    {
        if ($IsWindows)
        {
            if (Get-Command choco -ErrorAction Ignore)
            {
                choco install mkdocs -y --no-progress
                pip install "mkdocs-material==6.2.8" --force-reinstall --disable-pip-version-check
            }
            else
            {
                Throw "Choco not found, cannot install MKDocs"
            }
        }
        elseif ($IsMacOS)
        {
            brew install mkdocs
            pip3 install "mkdocs-material==6.2.8" --force-reinstall --disable-pip-version-check
        }
        else
        {
            Throw "MKDocs not supported on this operating system (Linux)"
        }
    }

    Push-Location ..
    mkdocs build
    Pop-Location
}

Action Publish -If {$Publish} {
    if (!$Script:TestResult)
    {
        Throw "Tests failed. No publish of package to feed allowed"
    }
    
    # PSGallery Feed
    if ($env:PsGalleryApiKey)
    {
        Publish-Module -Path (Join-Path $PSScriptRoot "../deploy/Output/$PSModule/$PSModuleVersion") -NuGetApiKey $env:PsGalleryApiKey #-WhatIf -Verbose
        Write-Info "Published to https://www.powershellgallery.com/packages/$PSModule"
    }
    else
    {
        Write-Info "No PSGallery Api key found"        
    }
}

$options = @{}
if (!$env:SYSTEM_TEAMPROJECT -and !$env:GITHUB_ACTIONS)
{
    $options = @{Container = $true; ContainerOptions = @{Root = '..'; Isolated = $true } }
}

if ($env:SYSTEM_ACCESSTOKEN)
{
    $env:SCRIPTBOOK_ACCESSTOKEN = $env:SYSTEM_ACCESSTOKEN
}

Start-Workflow $Actions @options