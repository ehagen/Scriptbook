param(
    $SampleParam1 = 'MyVal1'
)
Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello {
    Write-Info "Hello"
    Write-Info " Computer details"
    Write-Info "      Computer: $([Environment]::MachineName)"
    Write-Info "        WhoAmI: $([Environment]::UserName)"
    Write-Info "    Powershell: $($PSVersionTable.PsVersion)"
    Write-Info "            OS: $([Environment]::OSVersion.VersionString)"
    Write-Info "          Time: $((Get-Date).ToString('s'))"
    Write-Info "Current-folder: $(Get-Location)"    
}

Action GoodBy {
    Write-Info "GoodBy"
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
# !!add support for remote docker host in options with copy of files adn fix module path
# !!pass script parameters/param
Start-Workflow  -Name Container -Parameters @{SampleParam1 = $SampleParam1} -Container -ContainerOptions @{Image = 'mcr.microsoft.com/dotnet/sdk:5.0'; Isolated = $true; Root = '..'; }