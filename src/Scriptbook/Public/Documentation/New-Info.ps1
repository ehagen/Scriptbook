# experimental

Set-Alias -Name Info -Value New-Info -Scope Global -Force -WhatIf:$false
Set-Alias -Name Documentation -Value New-Info -Scope Global -Force -WhatIf:$false
function New-Info
{   
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [ScriptBlock] $Code,
        [string]$Comment,
        [Switch]$NoDisplay,
        [Switch]$Skip,
        [Switch]$AsDocumentation
    )

    if ($null -eq $Code)
    {
        Throw "No info script block is provided. (Have you put the open curly brace on the next line?)"
    }

    if ($Skip.IsPresent)
    {
        return
    }

    if ($PSCmdlet.ShouldProcess("New-Info"))
    {
        if ($PSCmdlet.MyInvocation.InvocationName -eq 'Documentation')
        {
            $AsDocumentation = $true
        }

        $text = $null
        if ($Comment)
        {
            $text = $Comment + [System.Environment]::NewLine
        }
        $text += Get-CommentFromCode -ScriptBlock $Code
    
        if ($AsDocumentation.IsPresent)
        {
            $ctx = Get-RootContext
            [void]$ctx.Infos.Add($text)
        }
        elseif (!($NoDisplay.IsPresent) -or ($VerbosePreference -eq 'Continue') )
        {
            Write-Info ($text | Out-String | Show-Markdown)
        }
    }
}

