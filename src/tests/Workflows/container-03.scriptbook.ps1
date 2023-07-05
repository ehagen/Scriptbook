Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

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

$instance = @{
    RequestCpu        = 1
    RequestMemoryInGb = 1.5
}

# enter your own details here, login with az login first
$group = @{
    ResourceGroupName = 'Aci-Sample-WordCount'
    Location          = 'WestEurope'
}

Action HelloOnAci -ContainerOptions @{Image = $image; Isolated = $true; Group = $group; Instance = $instance } {
    Write-Host "Hello"
    Write-Host " Computer details"
    Write-Host "      Computer: $([Environment]::MachineName)"
    Write-Host "        WhoAmI: $([Environment]::UserName)"
    Write-Host "    Powershell: $($PSVersionTable.PsVersion)"
    Write-Host "            OS: $([Environment]::OSVersion.VersionString)"
    Write-Host "          Time: $((Get-Date).ToString('s'))"
    Write-Host "Current-folder: $(Get-Location)"    
}

if ( ($env:SYSTEM_TEAMPROJECT -or $env:GITHUB_ACTIONS) -and $IsWindows)
{
    # containers on ado windows agent not supported
    return
}
Start-Workflow -Name Container