function Get-AnsiColoredString
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param([string]$String, [ValidateNotNull()][int]$Color, [switch]$NotSupported)

    # ref: https://en.wikipedia.org/wiki/ANSI_escape_code for color codes 
    # ref: https://duffney.io/usingansiescapesequencespowershell/
    if ($Global:ScriptbookSimpleHost -or $NotSupported.IsPresent)
    {
        return $String
    }
    else
    {
        return "`e[0;$($Color)m$($String)`e[0m"
    }
}