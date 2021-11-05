<#
.SYNOPSIS
Sets an environment variable

.DESCRIPTION
Sets an environment variable, supports empty environment variable

.PARAMETER Name
Name of the environment variable

.PARAMETER Value
Value of the environment variable

.PARAMETER ToUpper
Forces environment variable name to UpperCase

#>
function Set-EnvironmentVar
{
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        [alias('n')][string]
        $Name,
        [alias('v')][string]
        $Value,
        [alias('g')][switch]$Global,
        [switch]
        $ToUpper
    )

    if ($Name)
    {
        $n = if ($ToUpper.IsPresent) { $Name.ToUpper() } else { $Name }
        if (!$Value) 
        {
            $v = [char]0x2422
        }
        else
        {
            $v = $Value
        }
        $g = if ($Global.IsPresent) { 'Machine' } else { 'Process' }
        if ($PSCmdlet.ShouldProcess('Set-EnvironmentVar'))
        {
            [Environment]::SetEnvironmentVariable($n, $v, $g )
        }
    }
}