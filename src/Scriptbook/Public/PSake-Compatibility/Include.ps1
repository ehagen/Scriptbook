function Include
{
    [CmdletBinding()]
    param(
        [ScriptBlock] $Code
    )
    if ($null -eq $Code)
    {
        Throw "No include script block is provided. (Have you put the open curly brace on the next line?)"
    }
    & $code
}
