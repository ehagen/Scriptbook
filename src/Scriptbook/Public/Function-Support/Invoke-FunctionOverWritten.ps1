# experimental
function Invoke-FunctionOverWritten([alias('f', 'Func')]$aFunc)
{
    $v = Get-Alias -Name $aFunc -Scope Global -ErrorAction Ignore
    if ($v)
    {
        Remove-Item "Alias:\$aFunc" -Force -ErrorAction Ignore
    }
    &$aFunc
    if ($v)
    {
        New-Alias -Name $aFunc -Value $v.Definition -Scope Global
    }
}
