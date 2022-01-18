<#
.SYNOPSIS
Reads the Parameter values from Host / console

.DESCRIPTION
Reads the Parameter values Host / console

.PARAMETER Name
Name of created Parameters PowerShell variable

.EXAMPLE

Read-ParameterValuesFromHost -Name 'Params'

#>
function Read-ParameterValuesFromHost
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    if ($PSCmdlet.ShouldProcess("Read-ParameterValuesFromHost"))
    {
        $internalValue = @{}

        $ctx = Get-WorkflowContext
        if ($ctx.ContainsKey($Name))
        {
            # TODO Add SecureStringStorage support
            foreach ($parameter in $ctx[$Name].GetEnumerator())
            {
                $result = Read-Host -Prompt "$($Parameter.Key): default value = $($parameter.Value)"
                if (![string]::IsNullOrEmpty($result))
                {
                    [void]$internalValue.Add($parameter.Key, $result)
                }
                else
                {
                    [void]$internalValue.Add($parameter.Key, $parameter.Value)
                }
            }            
        }
        else
        {
            Throw "Invalid Parameters name found, '$Name' not does not exists"
        }

        if (!(Get-Variable -Name Context -ErrorAction Ignore -Scope Global))
        {
            Set-Variable -Name Context -Value @{ } -Scope Global
        }
        $Global:Context."$Name" = $internalValue
        Set-Variable -Name $Name -Value $internalValue -Scope Global    
    }
}