# experimental
function Remove-FunctionOverWrite
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param([alias('f', 'Func')]$aFunc)

    if ($PSCmdlet.ShouldProcess("Remove-FunctionOverWrite"))
    {    
        Remove-Item "Alias:\$aFunc" -Force -ErrorAction Ignore
    }
}
