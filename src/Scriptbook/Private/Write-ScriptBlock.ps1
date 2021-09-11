function Write-ScriptBlock($ScriptBlock)
{
    Write-StringResult (Invoke-Command -ScriptBlock $ScriptBlock)
}
