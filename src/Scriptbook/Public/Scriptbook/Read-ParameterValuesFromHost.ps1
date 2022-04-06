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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]    
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$Notice
    )

    $internalValue = [ordered]@{}

    $ctx = Get-WorkflowContext
    if ($ctx.ContainsKey($Name))
    {
        Write-Host ''
        if ($Notice)
        {
            Write-Host '==========================================================================' -ForegroundColor Blue
            Write-Host "$Notice $(if ($WhatIfPreference) { '(WhatIf)' })" -ForegroundColor Blue
        }
        Write-Host '==========================================================================' -ForegroundColor Blue
        Write-Host " Enter '$Name' data fields or use default value with [enter] key."
        Write-Host '   Use [shift][insert] keys if default Paste key is not working.'
        Write-Host '==========================================================================' -ForegroundColor Blue
        $l = 0
        foreach ($parameter in $ctx[$Name].GetEnumerator())
        {
            if ($parameter.Key.Length -gt $l)
            {
                $l = $parameter.Key.Length
            }
        }
        foreach ($parameter in $ctx[$Name].GetEnumerator())
        {
            $key = $parameter.Key.PadLeft($l)
            $secret = $false
            if ($null -ne $parameter.Value)
            {
                $secret = ($parameter.Value -is [SecureString]) -or (Test-IsSecureStringStorageObject $parameter.Value)
            }
            if ($secret)
            {
                $defaultValue = '***********'
            }
            else
            {
                $defaultValue = $parameter.Value
            }
            if (!($WhatIfPreference) )
            {
                $result = Read-Host -Prompt "$Key [$(Get-AnsiColoredString -String $defaultValue -Color 93)]"
            }
            else
            {
                $result = $null
            }
            if (![string]::IsNullOrEmpty($result))
            {
                if ($secret)
                {
                    [void]$internalValue.Add($parameter.Key, (ConvertTo-SecureString -String $result -AsPlainText))
                }
                else
                {
                    [void]$internalValue.Add($parameter.Key, $result)
                }
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
        Set-Variable -Name Context -Value @{ } -Scope Global -WhatIf:$false
    }
    $Global:Context."$Name" = $internalValue
    Set-Variable -Name $Name -Value $internalValue -Scope Global -WhatIf:$false
}