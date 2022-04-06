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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        $Path
    )

    if ($PSCmdlet.ShouldProcess($Path))
    {
        $ctx = Get-WorkflowContext
        if ($ctx.ContainsKey($Name))
        {
            if ($ctx[$Name] -is [PSCustomObject])
            {
                $object = $ctx[$Name]
            }
            else
            {
                $object = [PSCustomObject]$ctx[$Name]
            }

            function Set-Props
            {
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
                param($Object)

                foreach ($prop in $Object.PsObject.Properties)
                {
                    if ($prop.Value -is [SecureString])
                    {
                        $prop.Value = [SecureStringStorage]$prop.Value
                    }
                }
            }

            # fix SecureString references
            Set-Props $object

            $object | ConvertTo-Json -Depth 10 | Set-Content -Path $Path
        }
        else
        {
            Throw "Invalid Parameters name found, '$Name' not does not exists"
        }
    }
}