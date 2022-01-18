<#
.SYNOPSIS
Imports Parameters from File

.DESCRIPTION
Imports Parameters from File

.PARAMETER File
Name of the File
#>
function Import-Parameters
{
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $File
    )
    . $File
}