<#
.SYNOPSIS
Reads the Parameter values

.DESCRIPTION
Reads the Parameter values

.PARAMETER Name
Name of created Parameters PowerShell variable

.PARAMETER Path
Location of Parameters values in json format

.EXAMPLE

Read-ParameterValues -Name 'Params' -Path './my-parameter-values.json'

#>
function Read-ParameterValues
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        $Path
    )

    if ($PSCmdlet.ShouldProcess("Read-ParameterValues"))
    {
        $internalValue = Read-ParameterValuesInternal -Path $Path

        if (!(Get-Variable -Name Context -ErrorAction Ignore -Scope Global))
        {
            Set-Variable -Name Context -Value @{ } -Scope Global
        }
        $Global:Context."$Name" = $internalValue
        Set-Variable -Name $Name -Value $internalValue -Scope Global
    }
}