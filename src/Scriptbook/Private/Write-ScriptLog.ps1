function Write-ScriptLog($Msg, [switch]$AsError, [switch]$AsWarning, [switch]$AsAction, [switch]$AsWorkflow, [switch]$AsSkipped, [switch]$Verbose)
{
    $ctx = Get-RootContext
    if ($ctx.NoLogging -and (!$ctx.Verbose -or !$Verbose.IsPresent))
    {
        return
    }

    $colors = @{}
    if ($AsError.IsPresent)
    {
        [void]$colors.Add('ForegroundColor', 'White')
        [void]$colors.Add('BackgroundColor', 'Red')
    }
    elseif ($AsWarning.IsPresent)
    {
        [void]$colors.Add('ForegroundColor', 'White')
        [void]$colors.Add('BackgroundColor', 'Yellow')
    }
    elseif ($AsAction.IsPresent)
    {
        [void]$colors.Add('ForegroundColor', 'Blue')
    }
    elseif ($AsWorkflow.IsPresent -or $AsSkipped.IsPresent)
    {
        [void]$colors.Add('ForegroundColor', 'Magenta')
    }

    if ($Msg -and $Msg.GetType().Name -eq 'HashTable')
    {
        if ($Msg.ContainsKey('action'))
        {
            $m = $Msg.action;
            $Msg.Remove('action');
        }
        elseif ($Msg.ContainsKey('command'))
        {
            $m = $Msg.command;
            $Msg.Remove('command');
        }
        Write-Info $m @colors; Global:Write-OnLog -Msg $m
        if ($ctx.Verbose) 
        {
            Write-Info ($Msg.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { 'VERBOSE: @{0}:{1}' -f $_.key, $_.value }) -ForegroundColor Yellow
        }
    }
    else
    {
        Write-Info $Msg @colors
    }
}
