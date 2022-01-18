<#
.SYNOPSIS
Saves the Parameter values

.DESCRIPTION
Saves the Parameter values

.PARAMETER Name
Name of created Parameters PowerShell variable

.PARAMETER Path
Location of Parameters values in json format

.EXAMPLE

Save-ParameterValues -Name 'Params' -Path './my-parameter-values.json'

#>
function Save-ParameterValues
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        $Path
    )

    if ($PSCmdlet.ShouldProcess("Save-ParameterValues"))
    {
        $ctx = Get-WorkflowContext
        if ($ctx.ContainsKey($Name))
        {
            # TODO Add SecureStringStorage support
            $ctx[$Name] | ConvertTo-Json -Depth 10 | Set-Content -Path $Path
        }
        else
        {
            Throw "Invalid Parameters name found, '$Name' not does not exists"
        }
    }
}