Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello -Container -ContainerOptions @{Root = '..'; Context = 'default'; EnvVarPrefixes = @(); } {
    Write-Info "Hello"
    Write-Info " Computer details"
    Write-Info "      Computer: $([Environment]::MachineName)"
    Write-Info "        WhoAmI: $([Environment]::UserName)"
    Write-Info "    Powershell: $($PSVersionTable.PsVersion)"
    Write-Info "            OS: $([Environment]::OSVersion.VersionString)"
    Write-Info "          Time: $((Get-Date).ToString('s'))"
    Write-Info "Current-folder: $(Get-Location)"    
}

$image = 'mcr.microsoft.com/azure-powershell:latest'
# check arm64, not available yet...
try
{
    $r = docker version --format json | ConvertFrom-Json
    if ($r)
    {
        if ($r.Server.Arch -eq 'arm64')
        {
            $image = ''
        }
    }
}
catch
{
    $image = '' # issue with json on some platforms
}

Action HelloToo -ContainerOptions @{Image = $image; } {
    Write-Info "Hello"
    Write-Info " Computer details"
    Write-Info "      Computer: $([Environment]::MachineName)"
    Write-Info "        WhoAmI: $([Environment]::UserName)"
    Write-Info "    Powershell: $($PSVersionTable.PsVersion)"
    Write-Info "            OS: $([Environment]::OSVersion.VersionString)"
    Write-Info "          Time: $((Get-Date).ToString('s'))"
    Write-Info "Current-folder: $(Get-Location)"    
}

Action GoodBy -ContainerOptions @{ Image = 'mcr.microsoft.com/dotnet/sdk:6.0'; } -Isolated {
    Write-Host "GoodBy"
    Write-Host " Computer details"
    Write-Host "      Computer: $([Environment]::MachineName)"
    Write-Host "        WhoAmI: $([Environment]::UserName)"
    Write-Host "    Powershell: $($PSVersionTable.PsVersion)"
    Write-Host "            OS: $([Environment]::OSVersion.VersionString)"
    Write-Host "          Time: $((Get-Date).ToString('s'))"
    Write-Host "Current-folder: $(Get-Location)"    
}

$credential = New-Object System.Management.Automation.PSCredential ('mySecureUser', (ConvertTo-SecureString 'SamplePassword' -AsPlainText -Force))

Action HelloToo -ContainerOptions @{Registry = 'hello' ; Credentials = $credential } {
    Write-Info "Hello"
    Write-Info " Computer details"
    Write-Info "      Computer: $([Environment]::MachineName)"
    Write-Info "        WhoAmI: $([Environment]::UserName)"
    Write-Info "    Powershell: $($PSVersionTable.PsVersion)"
    Write-Info "            OS: $([Environment]::OSVersion.VersionString)"
    Write-Info "          Time: $((Get-Date).ToString('s'))"
    Write-Info "Current-folder: $(Get-Location)"    
}

if ( ($env:SYSTEM_TEAMPROJECT -or $env:GITHUB_ACTIONS) -and $IsWindows)
{
    # containers on ado windows agent not supported
    return
}
Start-Workflow -Name Container