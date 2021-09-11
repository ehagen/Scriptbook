<#
.SYNOPSIS
Asserts/Checks the supplied boolean condition 

.DESCRIPTION
Asserts/Checks the supplied boolean condition. Throws an exception with message details if fails

.PARAMETER Condition
Boolean value of condition to check

.PARAMETER Value
Actual value to check

.PARAMETER Operator
Check comparison operator like: -eq, -ne, -gt 

.PARAMETER Expected
Expected value for check

.PARAMETER Message
The message to display when assert fails

.EXAMPLE
Assert-Condition -Condition $false 'Error checking this condition'

.EXAMPLE
Assert -c (Test-Path $myFile) 'File not found'

.EXAMPLE
$cnt = 5
Assert-Condition ($cnt -eq 5) 'Error checking this condition'

.EXAMPLE
$cnt = 5
Assert-Condition ($cnt -eq 5) 'Error checking this condition'

.EXAMPLE
$cnt = 5
Assert-Condition -Value $cnt -Expected 5 'Error checking this condition'

.EXAMPLE
$cnt = 4
Assert-Condition -Value $cnt -Operator '-ne' -Expected 5 'Error checking this condition'

#>

Set-Alias -Name Assert -Value Assert-Condition -Scope Global -Force -WhatIf:$false
function Assert-Condition
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
    [CmdletBinding(DefaultParameterSetName = 'Condition', SupportsShouldProcess)]
    param(
        [bool][Alias('c')][Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Condition')]$Condition,
        [Alias('v', 'Actual', 'Real')][Parameter(Mandatory = $true, ParameterSetName = 'Comparison')]$Value,
        [Alias('o')][Parameter(ParameterSetName = 'Comparison')]$Operator = '-eq',
        [Alias('e', 'v2', 'Value2')][Parameter(Mandatory = $true, ParameterSetName = 'Comparison')]$Expected = '-eq',
        [Alias('m')]
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Condition')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Comparison')]
        [string]$Message
    )

    if ($PSCmdlet.ParameterSetName -eq 'Condition')
    {
        $expMsg = "Check: $Condition"
    }
    else
    {
        $expMsg = "Check: ($Value $Operator $Expected)"
    }
    if ($PSCmdlet.ShouldProcess("Assert-Condition", $expMsg))
    {
        if ($PSCmdlet.ParameterSetName -eq 'Condition')
        {
            if (-not $Condition)
            {
                Write-Verbose "Assert-Condition: $Message"
                Throw "Assert-Condition: $Message"
            }    
        }
        else
        {
            if ($Value -is [string])
            {
                $check = Invoke-Expression "'$Value' $Operator '$Expected'"
            }
            else
            {
                $check = Invoke-Expression "$Value $Operator $Expected"
            }
            if (-not $check)
            {
                Write-Verbose "Assert-Condition expected '$Expected' actual '$Value' with operation '$Operator' $Message"
                Throw "Assert-Condition: Expected '$Expected' Actual '$Value' with Operation '$Operator' $Message"
            }
        }
    }
}