function Start-ScriptInContainer
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        $File,
        $Options,
        $Parameters,
        $ActionName,
        $ActionType = 'Action',
        [switch]$Isolated,
        [scriptblock]$Code
    )

    if ($Options.ContainsKey('Group') -and $Options.ContainsKey('Instance') )
    {
        # no docker used
    }
    else
    {
        if ($null -eq (Get-Command docker -ErrorAction Ignore))
        {
            Write-Warning 'Docker not installed or found on this system'
            return
        }
    }

    # determine Scriptbook module path
    $m = Get-Module Scriptbook | Select-Object -Last 1
    if ($null -eq $m)
    {
        Throw "Scriptbook module not found in Start-ScriptInContainer"
    }
    $scriptbookModulePath = Split-Path $m.Path -Parent
    #TODO !!EH make this safe with correct location of current user modules
    #  /$home/.local/share/powershell/Modules
    #  $home\Documents\PowerShell\Modules
    $userModulePath = Split-Path $m.Path -Parent
    $userModulePath = (Resolve-Path (Join-Path $userModulePath '../..')).Path

    # script path
    if ($File)
    {
        $f = Resolve-Path $File
        $scriptPath = Split-Path $f -Parent
        $scriptName = Split-Path $f -Leaf
    }
    else
    {
        $scriptPath = Get-Location
        $scriptName = ''
    }

    $root = $null
    if ($Options.ContainsKey('Root') -and ![string]::IsNullOrEmpty($Options.Root))
    {
        $root = Resolve-Path $Options.Root
        if ($File)
        {
            if ($scriptPath.Contains($root.Path))
            {
                $replacePath = Join-Path $root.Path '/'
                $scriptName = Join-Path $scriptPath.Replace($replacePath, '') $scriptName
            }
            else
            {
                throw "Script $File not found in root path '$root', orphaned paths not supported."
            }
        }
        $scriptPath = $root.Path
    }

    # Get container Os (Windows or Linux)
    $platform = 'linux'
    $windowsContainer = $false
    if ($Options.ContainsKey('Group') -and $Options.ContainsKey('Instance') )
    {
        # no docker used
    }
    else
    {
        try
        {
            $r = docker version --format json | ConvertFrom-Json
            if ($r)
            {
                $windowsContainer = $r.Server.Os -eq 'windows'
                $platform = "$($r.Server.Os)/$($r.Server.Arch)"
            }
        }
        catch
        {
            # circumvent erratic behavior json output docker
        }
    }
    if ($Options.ContainsKey('Platform') -and ![string]::IsNullOrEmpty($Options.Platform))
    {
        if ($Options.Platform.Contains('linux'))
        {
            $windowsContainer = $false
            $platform = $Options.Platform
        }
        elseif ($Options.Platform.Contains('windows'))
        {
            $windowsContainer = $true
            $platform = $Options.Platform
        }
    }

    $containerName = ([Guid]::NewGuid().ToString('n')).SubString(0, 10)
    $cImage = 'mcr.microsoft.com/dotnet/sdk:7.0' #TODO !!EH hardcoded for now, move to Import-Module?
    if ($Options.ContainsKey('Image') -and ![string]::IsNullOrEmpty($Options.Image))
    {
        $cImage = $Options.Image
    }

    if ($Options.ContainsKey('Isolated'))
    {
        $Isolated = $Options.Isolated
    }

    $dockerCredentials = $null
    if ($Options.ContainsKey('Credentials') -and ($null -ne $Options.Credentials))
    {
        $dockerCredentials = $Options.Credentials
    }

    $dockerRegistry = $null
    if ($Options.ContainsKey('Registry') -and ($null -ne $Options.Registry))
    {
        $dockerRegistry = $Options.Registry
    }

    # map scriptbook module, user modules, and script
    if ($windowsContainer)
    {
        $workFolderName = 'Users\Public'
        $volumeVars = [System.Collections.ArrayList]@('-v', "`"$($scriptPath):c:\Workflow\Scripts`"", '-v', "`"$($userModulePath):c:\Workflow\ModulePath`"", '-v', "`"$($scriptbookModulePath):c:\Workflow\Scriptbook`"")
    }
    else
    {
        $workFolderName = 'home'
        $volumeVars = [System.Collections.ArrayList]@('-v', "`"$($scriptPath):/Workflow/Scripts`"", '-v', "`"$($userModulePath):/Workflow/ModulePath`"", '-v', "`"$($scriptbookModulePath):/Workflow/Scriptbook`"")
    }

    if ($env:RUNNER_TOOLSDIRECTORY)
    {
        [void]$volumeVars.Add('-v'); [void]$volumeVars.Add("`"$($env:RUNNER_TOOLSDIRECTORY):/opt/hostedtoolcache`"")
    }

    $envVars = [System.Collections.ArrayList]@('-e', 'InScriptbookContainer=True', '-e', "Script=$scriptName", '-e', "Action=$ActionName" )
    foreach ($item in Get-ChildItem env:SCRIPTBOOK_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }

    foreach ($item in Get-ChildItem env:ARM_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }
    foreach ($item in Get-ChildItem env:AZURE_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }

    # Add Azure DevOps & github env vars
    if ($env:SYSTEM_TEAMPROJECT)
    {
        foreach ($item in Get-ChildItem env:BUILD_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }
        foreach ($item in Get-ChildItem env:SYSTEM_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }
        foreach ($item in Get-ChildItem env:AGENT_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }
        foreach ($item in Get-ChildItem env:RUNNER_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }
    }
    if ($env:GITHUB_ACTIONS)
    {
        foreach ($item in Get-ChildItem env:GITHUB_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }
        foreach ($item in Get-ChildItem env:RUNNER_*) { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }
    }

    if ($Options.ContainsKey('EnvVarPrefixes'))
    {
        foreach ($prefix in $Options.EnvVarPrefixes)
        {
            foreach ($item in Get-ChildItem env:"$($prefix)*") { [void]$envVars.Add('-e'); [void]$envVars.Add("$($item.Name)=$($item.Value)"); }
        }
    }

    if (!$File)
    {
        #TODO !!EH Issue with $null values and PSCustomObjects, don't work with .ToString(). See Get-GlobalVarsForScriptblock
        $variablesToAdd = Get-GlobalVarsForScriptblock
    }

    $quiet = $false
    if ($Options.ContainsKey('Quiet'))
    {
        $quiet = $Options.Quiet
    }

    $detailed = $false
    if ($Options.ContainsKey('Detailed'))
    {
        $detailed = $Options.Detailed
    }
    if ($detailed)
    {
        $quiet = $false
    }

    $importCode = @"
`$inContainer = `$env:InScriptbookContainer;
if (`$inContainer)
{
    `$isolatedTag = '';
    if (`$$Isolated)
    {
        `$isolatedTag = ' Isolated';
    }

    `$typeTag = '$ActionType';
    `$typeName = `$env:Action;
    if (`$env:Script)
    {
        `$typeTag = 'script';
        `$typeName = `$env:Script;
    }

    $(
        if (!$quiet)
        {
@"
            Write-Host ''.PadRight(78, '=');
            Write-Host "Running `$typeTag '`$typeName'`$isolatedTag";
            Write-Host " -In Container '$cImage' On '`$([Environment]::OSVersion.VersionString)'";
            Write-Host " -As `$([Environment]::UserName) With 'PowerShell `$(`$PSVersionTable.PsVersion)' At `$((Get-Date).ToString('s'))";
            Write-Host ''.PadRight(78, '=');
"@        
        }
        if ($detailed)
        {
@"
            Write-Host 'Environment variables:'
            Get-ChildItem env:* | Sort-Object -Property Name | Out-String | Write-Host;
"@        

        }
    )
}

$(
    if (!$Isolated)
    {
        if ($windowsContainer)
        {
@"
            `$env:PSModulePath = `$env:PSModulePath + ';c:\Workflow\ModulePath' + ';c:\Workflow\Scriptbook';
"@            
        }
        else
        {
@"            
            `$env:PSModulePath = `$env:PSModulePath + ':/Workflow/ModulePath' + ':/Workflow/Scriptbook';
"@            
        }
@"            
        Set-Location '/Workflow/Scripts';
"@            

    }
    else
    {
        if ($File)
        {
            if ($windowsContainer)
            {
@"
                `$env:PSModulePath = `$env:PSModulePath + ';c:\$workFolderName\Scriptbook';
                Set-Location '\$workFolderName\Scripts';
"@
            }
            else
            {
@"                    
                `$env:PSModulePath = `$env:PSModulePath + ':/$workFolderName/Scriptbook';
                Set-Location '/$workFolderName/Scripts';
"@
            }
        }
    }
)

Write-Verbose "Current location: `$(Get-Location)";

$(
    if ($File)
    {
        # run script
        Write-Output "&`"./$scriptName`" -WhatIf:!$WhatIfPreference"
    }
    else
    {
        if (!$Isolated)
        {
            # import module
            Write-Output "Import-Module /Workflow/Scriptbook/Scriptbook.psm1 -Args @{ Quiet = `$true };"
            # importing  vars
            $variablesToAdd
        }
        if ($WhatIfPreference)
        {
            Write-Output "Write-Host 'What if: Performing the operation `"Invoke`" on target `"$ActionName`"'; "
            Write-Output "return;"
        }
    }
)

"@

    $finishCode = @"
`$inContainer = `$env:InScriptbookContainer;
if (`$inContainer)
{
    `$typeTag = '$ActionType';
    `$typeName = `$env:Action;
    if (`$env:Script)
    {
        `$typeTag = 'script';
        `$typeName = `$env:Script;
    }

    $(
        if (!$quiet)
        {
@"
            Write-Host ''.PadRight(78, '=');
            Write-Host "Finished `$typeTag '`$typeName'";
            Write-Host ''.PadRight(78, '=');
"@        
        }
    )

    }
"@

    if ($Isolated.IsPresent)
    {
        $volumeVars = @()
    }

    if ($ActionName)
    {
        $importCode = [scriptblock]::Create($importCode + "`n" + $Code.ToString() + "`n" + $finishCode)
    }
    else
    {
        $importCode = $importCode + "`n" + $finishCode
    }

    $encodedCommand = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($importCode))

    $dockerContext = $null
    if ($Options.ContainsKey('Context') -and ![string]::IsNullOrEmpty($Options.Context))
    {
        $dockerContext = $Options.Context
    }

    $useSeparateDockerCommands = $true
    if ($Options.ContainsKey('Run'))
    {
        $useSeparateDockerCommands = -not $Options.Run
    }

    function StartWithDocker
    {
        [CmdletBinding()]
        param(
            [Parameter(ValueFromRemainingArguments)]$Remaining
        )
        $a = $null
        foreach ($item in $Remaining)
        {
            $a += "$($item) "
        }
        Write-Verbose "StartWithDocker $($a)"
        $r = Start-ShellCmd -Progress -Command docker -Arguments $a
        return $r
    }

    if ($Options.ContainsKey('Group') -and $Options.ContainsKey('Instance') )
    {
        $m = Get-Module 'Az.ContainerInstance' -ErrorAction Ignore
        if ($null -eq $m)
        {
            # try to import module
            Import-Module Az.ContainerInstance
        }

        $m = Get-Module 'Az.ContainerInstance' -ErrorAction Ignore
        if ($null -eq $m)
        {
            throw 'Required Az.*, Az.ContainerInstance module not found in start Azure Container Instances, use Import-Module Az or Install-Module Az -Scope CurrentUser to install the Azure PowerShell Az module(s) and login with Connect-Az before running this Action'
        }

        # try to connect with default azure environment variable service principle credentials
        if ($env:ARM_CLIENT_ID)
        {
            Connect-AzAccount -Credential (New-Object System.Management.Automation.PSCredential ($env:ARM_CLIENT_ID, (ConvertTo-SecureString -String $env:ARM_CLIENT_SECRET -AsPlainText -Force))) -Tenant $env:ARM_TENANT_ID -ServicePrincipal -Subscription $env:ARM_SUBSCRIPTION_ID | Out-Null
        }
            
        if ($null -eq (Get-AzContext))
        {
            throw 'No AzContext found in start Azure Container Instances, are you logged in to Azure with Connect-Az before running this Action'
        }

        if (!$Isolated)
        {
            throw 'Only Isolated mode supported for now in Azure Container Instances, no volume mapping yet'
        }

        # create container instance
        $instance = @{}
        if ($Options.ContainsKey('Instance'))
        {
            $instance = $Options.Instance
        }
        if (!($instance.ContainsKey('Name')))
        {
            # max size container name is 63 characters with following allowed characters '[a-z0-9]([-a-z0-9]*[a-z0-9])?'
            # TODO: validate on reg
            if ($ActionName)
            {
                $instance.Name = "scriptbook-$($ActionName.ToLower())"
            }
            else
            {
                $instance.Name = "scriptbook"
            }
        }
        if (!($instance.ContainsKey('Image')))
        {
            $instance.Image = $cImage
        }
        if (!($instance.ContainsKey('Command')))
        {
            $instance.Command = "tail", "-f", "/dev/null"
        }
        $container = New-AzContainerInstanceObject @instance

        # setup container group
        $group = @{}
        if ($Options.ContainsKey('Group'))
        {
            $group = $Options.Group
        }
        if (!($group.ContainsKey('ResourceGroupName')))
        {
            Write-Warning "Aci Container Group: Required ResourceGroupName property not found in '$($group)', provide property in Group HashTable, using default ResourceGroupName 'rg-scriptbook'"
            $group.ResourceGroupName = 'rg-scriptbook'
        }
        if (!($group.ContainsKey('Location')))
        {
            Write-Warning "Aci Container Group: Required Location property not found in '$($group)', provide property in Group HashTable, use for example 'WestEurope', using default Location 'WestEurope'"
            $group.Location = 'WestEurope'
        }
        if (!($group.ContainsKey('Name')))
        {
            $group.Name = "cg-scriptbook-$($containerName)"
        }
        $group.Container = $container
        $group.Location = $group.location
        try
        {
            # create container group
            New-AzContainerGroup @group | Out-Null

            # execute command
            Invoke-AzContainerInstanceCommand -ContainerGroupName $group.Name -ResourceGroupName $group.ResourceGroupName -ContainerName $instance.Name -Command "pwsh -NonInteractive -NoLogo -OutputFormat Text -ExecutionPolicy Bypass -EncodedCommand $encodedCommand"

            if ($Options.ContainsKey('Log') -and $Options.Log)
            {
                Get-AzContainerInstanceLog -ContainerGroupName $group.Name -ResourceGroupName $group.ResourceGroupName -ContainerName $instance.Name
            }
        }
        finally
        {
            # stop execution if not halted
            Stop-AzContainerGroup -Name $group.Name -ResourceGroupName $group.ResourceGroupName -ErrorAction Continue | Out-Null

            # remove container group
            $removeGroup = $Options.ContainsKey('Debug') -and $Options.Debug
            if (!$removeGroup)
            {
                Remove-AzContainerGroup -Name $group.Name -ResourceGroupName $group.ResourceGroupName -ErrorAction Continue | Out-Null
            }
        }
    }
    else
    {
        $containerStarted = $false
        try
        {
            Write-Verbose "Running container '$containerName' with image '$cImage' in $(Get-Location)"

            if ($dockerContext)
            {
                $r = docker context use $dockerContext
                if ($LASTEXITCODE -ne 0) { Throw "Error in docker context switch $dockerContext : $LastExitCode $r" }
            }

            if ($dockerCredentials -and $dockerRegistry)
            {
                $r = $dockerCredentials.Password | docker login $dockerRegistry -u $dockerCredentials.Username --password-stdin
                if ($LASTEXITCODE -ne 0) { Throw "Error in docker login : $LastExitCode $r" }
            }
    
            if ($useSeparateDockerCommands)
            {
                $r = StartWithDocker create @envVars $volumeVars --platform=$platform --tty --interactive --name "$containerName" $cImage
                if ($LASTEXITCODE -ne 0) { Throw "Error in docker create for container '$containerName' with image '$cImage' on platform '$platform' : $LastExitCode $r" }

                if ($File -and $Isolated.IsPresent)
                {
                    # copy script and modules when isolated
                    docker cp "$scriptPath" "$($containerName):/$workFolderName/Scripts"
                    if ($m.RepositorySourceLocation)
                    {
                        $tmp = Join-Path (Get-TempPath) (New-Guid)
                        New-Item $tmp -ItemType Directory | Out-Null
                        try
                        {
                            $sPath = Join-Path (Join-Path $tmp Scriptbook ) $m.Version
                            Copy-Item $scriptbookModulePath $sPath -Recurse
                            docker cp "$tmp" "$($containerName):/$workFolderName/Scriptbook"
                        }
                        finally
                        {
                            Remove-Item $tmp -Recurse -Force -ErrorAction Ignore
                        }
                    }
                    else
                    {
                        docker cp "$scriptbookModulePath" "$($containerName):/$workFolderName/Scriptbook"
                    }
                }
                $r = docker start "$containerName"
                if ($LASTEXITCODE -ne 0) { Throw "Error in docker start for container '$containerName' with image '$cImage' on platform '$platform' : $LastExitCode $r" }
                $containerStarted = $true

                $r = Start-ShellCmd -Progress -Command 'docker' -Arguments "exec `"$containerName`" pwsh -NonInteractive -NoLogo -OutputFormat Text -ExecutionPolicy Bypass -EncodedCommand $encodedCommand"
                if ($r.ExitCode -ne 0) { Throw "Error in docker exec for container '$containerName' with image '$cImage' on platform '$platform' : $LastExitCode" }
                if ([string]::IsNullOrEmpty($r.StdOut)) { Throw "No output found in 'docker exec' command" }
                if (![string]::IsNullOrEmpty($r.StdErr)) 
                {
                    Throw "Errors found in output 'docker exec' command $($r.StdErr)"
                }
            }
            else
            {
                StartWithDocker run @envVars $volumeVars --platform=$platform --name "$containerName" $cImage pwsh -NonInteractive -NoLogo -OutputFormat Text -ExecutionPolicy Bypass -EncodedCommand $encodedCommand
                if ($LASTEXITCODE -ne 0) { Throw "Error in docker run for container '$containerName' with image '$cImage' on platform '$platform' : $LastExitCode" }
            }
        }
        finally
        {
            try
            {
                if ($containerStarted)
                {
                    $r = docker stop "$containerName"
                    if ($LASTEXITCODE -ne 0) { Throw "Error in docker stop for container '$containerName' : $LastExitCode $r" }
                }
            }
            finally
            {
                $r = docker container ls -a -f name=$containerName
                if ($LASTEXITCODE -ne 0) { $r = $containerName } # some context's don't support container ls --> always try to remove

                if ( "$r".Contains($containerName))
                {
                    $r = docker rm --force $containerName
                    if ($LASTEXITCODE -ne 0) { Throw "Error in docker remove for container '$containerName' output: $r" }
                }
            }
        }
    }
}