<#
.SYNOPSIS
Gets an environment variable

.DESCRIPTION
Gets an environment variable, supports empty environment variable and case sensitivity

.PARAMETER Name
Name of the environment variable

.PARAMETER Default
Default value of the environment variable when not found

.PARAMETER IgnoreCasing
Ignores casing by checking ToLower and ToUpper variants

#>
function Get-EnvironmentVar
{
    param([alias('n')][string]$Name, [alias('d')][string]$Default = $null, [switch]$IgnoreCasing)

    $r = [Environment]::GetEnvironmentVariable($Name);
    if ($null -eq $r -and $IgnoreCasing.IsPresent)
    {
        $r = [Environment]::GetEnvironmentVariable($Name.ToLower());
        if ($null -eq $r) 
        {
            $r = [Environment]::GetEnvironmentVariable($Name.ToUpper());
        }
    }
    if ($r -eq [char]0x2422) { $r = '' }
    if (($r -eq '') -or ($null -eq $r)) { $r = $Default }
    if ($r -eq '') { return $null } else { return $r }
}