<#
.SYNOPSIS
Returns if PowerShell console (pwsh) is started in Non Interactive mode

.DESCRIPTION
Returns if PowerShell console (pwsh) is started in Non Interactive mode

#>
function Get-IsPowerShellStartedInNonInteractiveMode
{
    if ( ((Get-Host).Name -eq 'ConsoleHost') -and ([bool]([Environment]::GetCommandLineArgs() -like '-noni*')) )
    {
        return $true
    }
        else
    {
        return $false
    }
}