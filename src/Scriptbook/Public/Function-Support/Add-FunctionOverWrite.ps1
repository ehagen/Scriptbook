# experimental
function Add-FunctionOverWrite([alias('f', 'Func')]$aFunc, [alias('n', 'WithFunc')]$aWithFunc)
{
    Remove-Item "Alias:\$aFunc" -Force -ErrorAction Ignore
    New-Alias -Name $aFunc -Value $aWithFunc -Scope Global
}