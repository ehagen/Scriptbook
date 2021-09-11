<#
.SYNOPSIS
Checks the minimum required version of command

.DESCRIPTION
Checks the minimum required version of command. Command includes Powershell commands and native commands. Select -Minimum to allow higher major versions.
Default higher minimum versions are allowed. For example Version is 4.1 then 4.1-4.9  are valid versions. remarks. Version/Minimum check only works on Windows.

.PARAMETER Command
The command

.PARAMETER Version
Version of command required. Higher minor versions are allowed

.PARAMETER Minimum
Minimum version of command required. Higher Major version are allowed

.EXAMPLE
Assert-Version -Command cmd -Version 1.0
#>
function Assert-Version([Parameter(Mandatory = $true)][string]$Command, [Parameter(Mandatory = $true)][string]$Version, [switch]$Minimum)
{
    if (!$IsWindows)
    {
        $cmdNative = $Command.Replace('.exe', '')
    }
    else
    {
        $cmdNative = $Command
    }
    $cm = Get-Command $cmdNative -ErrorAction Ignore
    if ($cm)
    {
        if ($IsWindows)
        {
            $v = [Version]$Version
            if ($Minimum.IsPresent)
            {
                if ($cm.Version.Major -ge $v.Major)
                {
                    return
                }
            }
            else
            {
                if ($cm.Version.Major -eq $v.Major)
                {
                    if ($cm.Version.minor -ge $v.Minor)
                    {
                        # okay
                        return
                    }
                }
            }
            Throw "Invalid version of $Command found '$($cm.Version)' expected $v"
        }
        else
        {
            Write-Verbose "Assert-Version: No version/Minimum check on platforms other than Windows"
        }
    }
    else
    {
        Throw "$Command not installed"
    }
}