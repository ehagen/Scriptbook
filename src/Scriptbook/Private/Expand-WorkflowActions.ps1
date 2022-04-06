function Expand-WorkflowActions
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param($Actions)

    $ctx = Get-RootContext
    $expandedActions = [System.Collections.ArrayList]@()
    foreach ($action in $Actions)
    {
        if ($action.Contains('*'))
        {
            foreach ($item in $ctx.Actions.GetEnumerator())
            {
                $n = $item.Value.DisplayName
                if ($n -like $action)
                {
                    if (!$expandedActions.Contains($n) -and !$expandedActions.Contains("!$n"))
                    {
                        [void]$expandedActions.Add($n)
                    }
                }
            }
        }
        else
        {
            [void]$expandedActions.Add($action)
        }
    }
    return $expandedActions
}