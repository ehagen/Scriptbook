# TODO !!EH Convert $Script:PsakeProperties to list of scriptblocks to circumvent multiple allowed properties statements in psake scripts
function Properties
{
    [CmdletBinding()]
    param(
        [ScriptBlock] $Code
    )
    if ($null -eq $Code)
    {
        Throw "No properties script block is provided. (Have you put the open curly brace on the next line?)"
    }
    $Script:PsakeProperties = $Code
}
