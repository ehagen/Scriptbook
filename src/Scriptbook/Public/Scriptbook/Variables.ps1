function Variables
{
    [CmdletBinding()]
    param(
        $Name,
        [ScriptBlock] $Code
    )
    if ($null -eq $Code)
    {
        Throw "No variables script block is provided with HashTable. (Have you put the open curly brace on the next line?)"
    }
    try
    {
        if (Get-Variable -Name $Name -ErrorAction Ignore -Scope Global)
        {
            Write-Warning "Variable $Name already defined"
        }
        Set-Variable -Name $Name -Value (Invoke-Command $Code) -Scope Global
    }
    catch
    {
        Write-Warning "Error setting '$Name' variable to $Code"
        Write-Warning "Only HashTable @{ Name = 'default'; Name2 = 'default2'}"
    }
}
