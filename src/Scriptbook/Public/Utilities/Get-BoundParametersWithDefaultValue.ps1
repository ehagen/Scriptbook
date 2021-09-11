<#
.SYNOPSIS
Get Invocation Bound parameters with default values.

.DESCRIPTION
Get Invocation Bound parameters with default values. $PSBoundParameters does not contain default values

.PARAMETER Invocation
Contains the $MyInVocation of the script / function

.EXAMPLE

Script with :

[CmdletBinding(SupportsShouldProcess = $True)]
Param(
    $Param1,
    $Param2,
)

$parameters = Get-BoundParametersWithDefaultValue $MyInvocation

Now call script with @parameters

. ./myScript @parameters

or function with @parameters

myFunction @parameters

#>
function Get-BoundParametersWithDefaultValue
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
    param(
        $Invocation = $Global:MyInvocation
    )

    $parameters = @{}
    foreach ($parameter in $Invocation.MyCommand.Parameters.GetEnumerator())
    {
        try
        {
            $key = $parameter.Key
            $val = Get-Variable -Name $key -ErrorAction Stop | Select-Object -ExpandProperty Value -ErrorAction Stop
            [void]$parameters.Add($key, $val)
        }
        catch {}
    }
    return $parameters
}