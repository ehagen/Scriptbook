param(
    $SampleParam1 = 'MyVal1'
)
Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber 
}

Import-Module Scriptbook

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

Start-Workflow  -Name Container -Parameters @{SampleParam1 = $SampleParam1} -Container -ContainerOptions @{Image = 'mcr.microsoft.com/dotnet/sdk:5.0'; Isolated = $true; Root = '..'; }