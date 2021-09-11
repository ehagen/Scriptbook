[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
param(
    [parameter(Mandatory = $false)][HashTable]$ImportVars
)

Write-Verbose "Start loading Scriptbook module";

# check if single file module
if (Test-Path (Join-Path $PSScriptRoot Public))
{
    $dotSourceParams = @{
        Filter      = '*.ps1'
        Recurse     = $true
        ErrorAction = 'Stop'
    }
    $public = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public') @dotSourceParams )
    $private = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private/*.ps1') @dotSourceParams)
    foreach ($import in @($private + $public))
    {
        try
        {
            . $import.FullName
        }
        catch
        {
            throw "Unable to dot source [$($import.FullName)]"
        }
    }
}

$verbose = $false
if ($ImportVars -and $ImportVars.ContainsKey('Verbose'))
{
    $verbose = $ImportVars.Verbose
}
if ($verbose)
{
    $VerbosePreference = 'Continue'
}

$strict = $true
if ($ImportVars -and $ImportVars.ContainsKey('NoStrict'))
{
    $strict = -not $ImportVars.NoStrict
}
if ($strict)
{
    Set-StrictMode -Version Latest
}

$quiet = $false
if ($ImportVars -and $ImportVars.ContainsKey('Quiet'))
{
    $quiet = $ImportVars.Quiet
}
if (!($quiet))
{
    $module = 'Scriptbook'
    $scriptDir = Split-Path $MyInvocation.MyCommand.Path
    $manifestPath = Join-Path $scriptDir "$module.psd1"
    $manifest = Test-ModuleManifest -Path $manifestPath -WarningAction SilentlyContinue
    $version = $manifest.Version.ToString()
    $copyright = $manifest.Copyright
    $author = $manifest.Author
    Write-Host "$module Version $version by $author"
    Write-Host "Proudly created in Schiedam (NLD), $copyright"
}

$core = $false
if ($ImportVars -and $ImportVars.ContainsKey('Core'))
{
    $core = $ImportVars.Core
}
if ($core)
{
    if ($PSVersionTable.PSVersion.Major -lt 6)
    {
        Write-Host ''.PadRight(78, '=')
        Throw "PowerShell version $($PSVersionTable.PSVersion) not supported by this Script"        
    }
}

$checkModules = $true
$cacheTimeFile = Join-Path $home './cacheTimeFile.json'

$importFormat = 'Scriptbook'
# load dependencies from file if not override by arguments
if ($null -eq $ImportVars -or ($ImportVars.ContainsKey('SettingsFile') -or ($ImportVars.ContainsKey('Quiet') -and $ImportVars.Count -eq 1)) )
{
    if ($ImportVars -and $ImportVars.ContainsKey('SettingsFile'))
    {
        $importFile = $ImportVars.SettingsFile
    }
    else
    {
        $importFile = ''    
    }
    $scriptName = $Script:MyInvocation.ScriptName
    if ([string]::IsNullOrEmpty($scriptName))
    {
        $scriptName = Join-Path $PSScriptRoot 'Scriptbook.ps1'
    }
    if (Test-Path variable:Profile)
    {
        $profileLocation = Join-Path (Split-Path $Profile) 'Scriptbook.psd1'
    }
    else
    {
        $profileLocation = ''
    }
    $importFiles = @( 
        $importFile,
        [IO.Path]::ChangeExtension($scriptName, 'psd1'),
        [IO.Path]::ChangeExtension((Join-Path (Split-Path $scriptName) ".$(Split-Path $scriptName -Leaf)"), 'psd1'),
        (Join-Path (Split-Path $scriptName) 'Scriptbook.psd1'),
        (Join-Path (Split-Path $scriptName) '.Scriptbook.psd1'),
        './depends.psd1',
        './variables.psd1',
        './.depends.psd1',
        './.variables.psd1',
        './requirements.psd1',
        $profileLocation
    )
    foreach ($f in $importFiles)
    {
        if ( ![string]::IsNullOrEmpty($f) -and (Test-Path -Path $f -ErrorAction Ignore) )
        {
            $ImportVars = Import-PowerShellDataFile -Path $f
            if ($f.Contains('requirements.psd1'))
            {
                $importFormat = 'Requirements'
            }
            break;
        }
    }
    if ($null -eq $ImportVars)
    {
        $ImportVars = @{}
    }
}

if ($ImportVars -and $importFormat -eq 'Requirements')
{    
    <#
        Import modules from requirements format: https://docs.microsoft.com/azure/azure-functions/functions-reference-powershell

        sample:
            @{
                'Az.Accounts' = '2.*'
                'Az.Compute'  = '4.*'
            } 
    #>
    $ImportVarsNew = @{}
    $modules = [System.Collections.ArrayList]@()
    foreach ($m in $ImportVars.GetEnumerator())
    {
        $modules.Add(@{ 
                Module         = $m.Key
                MinimumVersion = $m.Value
            }
        ) | Out-Null
    }
    $ImportVarsNew.Add('Depends', $modules) | Out-Null
    $ImportVars = $ImportVarsNew
}

if ($ImportVars.ContainsKey('Reset') -and $ImportVars.Reset)
{
    # default is reset
}
else
{
    if (Test-Path $cacheTimeFile)
    {
        # determine if we need to load the modules from repository again
        # now we check once a day the repository feed if new version are available 
        # to speed up the start-time of our workbooks
        $moduleCache = Get-Content -Path $cacheTimeFile -Raw | ConvertFrom-Json
        if ($moduleCache.Time.Value -is [string])
        {
            
            $md = [System.DateTime]::Parse($moduleCache.Time.Value).Date
        }
        else
        {
            $md = $moduleCache.Time.Value.Date
        }
        if ($md -eq ((Get-Date).Date))
        {
            $checkModules = $false
        }
    }
}

if ($checkModules -eq $true)
{
    Set-Content -Path $cacheTimeFile -Value (@{ Time = (Get-Date) } | ConvertTo-Json) -Force
    Write-Verbose 'Loading modules...'
}

$depends = $null
if ($ImportVars -and $ImportVars.ContainsKey('Depends'))
{
    $depends = $ImportVars.Depends
}

if ($depends)
{
    # TODO !!EH Add install modules from git repo
    # TODO !!EH Add cache module option (create copy local and import from local), used in scenarios without internet access (deployments) / isolated containers
    Write-Host "Loading Scriptbook dependencies..."
    $pref = $global:ProgressPreference
    $global:ProgressPreference = 'SilentlyContinue'
    foreach ($dependency in $depends)
    {
        if (!$dependency.ContainsKey('Module'))
        {
            throw "Module not found in dependency: $dependency"
        }

        $skip = if ($dependency.ContainsKey('Skip')) { $dependency.Skip } else { $false }
        if ($skip)
        {
            continue
        }

        $minimumVersion = if ($dependency.ContainsKey('MinimumVersion')) { $dependency.MinimumVersion } else { '' }
        $maximumVersion = if ($dependency.ContainsKey('MaximumVersion')) { $dependency.MaximumVersion } else { '' }

        $extraParams = @{}
        $credentialLocation = if ($dependency.ContainsKey('Credential')) { $dependency.Credential } else { $null }
        if ($credentialLocation)
        {
            if ($credentialLocation.StartsWith('https://'))
            {
                # dependency on TD.Util Module, load this module first
                if (Get-Command Get-AzureDevOpsCredential -ErrorAction Ignore)
                {
                    $cred = Get-AzureDevOpsCredential -Url $credentialLocation
                    $extraParams.Add('Credential', $cred) | Out-Null
                }
            }
            else
            {
                try
                {
                    $cred = Get-LocalCredential -Name $credentialLocation
                    $extraParams.Add('Credential', $cred) | Out-Null
                }
                catch
                {
                    Write-Warning $_.Exception.Message
                }                
            }
        }

        $repository = if ($dependency.ContainsKey('Repository')) { $dependency.Repository } else { 'PSGallery' }
        if ($repository -ne 'PSGallery')
        {
            $repo = Get-PSRepository -Name $repository -ErrorAction Ignore
            if ($null -eq $repo)
            {
                $repositoryUrl = if ($dependency.ContainsKey('RepositoryUrl')) { $dependency.RepositoryUrl } else { $null }
                if ($repositoryUrl)
                {
                    if (Get-Command Register-AzureDevOpsPackageSource -ErrorAction Ignore)
                    {
                        Register-AzureDevOpsPackageSource -Name $repository -Url $repositoryUrl @extraParams
                    }
                    else
                    {
                        Register-PSRepository -Name $repository -SourceLocation $repositoryUrl -InstallationPolicy Trusted @extraParams
                    }
                }
            }
        }

        if (Get-Module -Name $dependency.Module -ListAvailable -ErrorAction Ignore)
        {
            if ($checkModules)
            {
                if ($null -ne (Get-InstalledModule -Name $dependency.Module -ErrorAction Ignore) )
                {                
                    $force = if ($dependency.ContainsKey('Force')) { $dependency.Force } else { $false }
                    if ($minimumVersion)
                    {
                        $v1 = (Get-Module -Name $dependency.Module -ListAvailable | Select-Object -First 1).Version
                        $v2 = [version]$minimumVersion
                        if ($v2 -gt $v1)
                        {
                            Write-Verbose "Updating module $($dependency.Module) with MinimumVersion $minimumVersion"
                            Update-Module -Name $dependency.Module -Force:$force -RequiredVersion $minimumVersion @extraParams
                        }
                    }
                    else
                    {
                        Write-Verbose "Updating module $($dependency.Module) with MaximumVersion $maximumVersion"
                        Update-Module -Name $dependency.Module -Force:$force -MaximumVersion $maximumVersion @extraParams
                    }
                }
                else
                {
                    Write-Warning "Module $($dependency.Module) not installed by Install-Module, cannot update module via Update-Module, using forced Install-Module"
                    Write-Verbose "Installing module $($dependency.Module)"
                    Install-Module -Name $dependency.Module -Force -Repository $repository -Scope CurrentUser -MinimumVersion $minimumVersion -MaximumVersion $maximumVersion -AllowClobber @extraParams
                }
            }
        }
        else
        {
            Write-Verbose "Installing module $($dependency.Module)"
            # TODO !!EH using -Force to install from untrusty repositories or do we need to handle this via Force attribute
            Install-Module -Name $dependency.Module -Force -Repository $repository -Scope CurrentUser -MinimumVersion $minimumVersion -MaximumVersion $maximumVersion -AllowClobber @extraParams
        }

        if ($dependency.ContainsKey('Args'))
        {
            Import-Module -Name $dependency.Module -ArgumentList $dependency.Args -Global
        }
        else
        {
            Import-Module -Name $dependency.Module -Global
        }
    }
    $global:ProgressPreference = $pref
}

$variables = $null
if ($ImportVars -and $ImportVars.ContainsKey('Variables'))
{
    $variables = $ImportVars.Variables
}
if ($variables)
{
    foreach ($kv in $variables.GetEnumerator())
    {
        Set-Variable -Scope Global -Name $kv.Key -Value $kv.Value -Force
    }
}

# snapshot global vars, excluding parameters
$Global:GlobalVarNames = @{}
Get-Variable -Scope Global | ForEach-Object {
    if (!$_.Attributes)
    {
        $Global:GlobalVarNames.Add($_.Name, $null) | Out-Null
    }
    elseif ($_.Attributes.GetType().Name -ne 'PSVariableAttributeCollection' -or $_.Attributes.Count -eq 0)
    {
        $Global:GlobalVarNames.Add($_.Name, $null) | Out-Null
    }
    elseif ($_.Attributes[0].GetType().Name -ne 'ParameterAttribute')
    {
        $Global:GlobalVarNames.Add($_.Name, $null) | Out-Null
    }
}

# cleanup module script scope
@(
    'variables',
    'author',
    'checkModules',
    'cacheTimeFile',
    'copyright',
    'depends',
    'dotSourceParams',
    'importFile',
    'importFiles',
    'importFormat',
    'ImportVars',
    'manifest',
    'manifestPath',
    'module',
    'moduleCache',
    'private',
    'profileLocation',
    'public',
    'quiet',
    'scriptDir',
    'scriptName',
    'version',
    'verbose',
    'f',
    'strict',
    'import'
) | ForEach-Object { Remove-Variable -Force -ErrorAction Ignore -Scope Script -Name $_ }

Write-Verbose "Finished loading Scriptbook module";
# end import
;

