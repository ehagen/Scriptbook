<#
.SYNOPSIS
    Returns if defined Powershell function has no body, aka is empty
#>
function Get-IsPSFunctionDefinitionEmpty
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
    param([alias('Function')]$aFunction)

    try
    {
        $c = Get-Command $aFunction
        if ($c)
        {
            $d = $c.Definition
            if ($d)
            {
                return $d.Trim().Length -eq 0
            }
            else
            {
                return $true
            }
        }
    }
    catch
    {
        # ignore
    }
    return $false
}
