function Get-AnsiColoredString([string]$String, [int]$Color)
{
    if ($Global:ScriptbookSimpleHost)
    {
        return $String
    }
    else
    {
        return "`e[0;$($Color)m$($String)`e[0m"
    }
}