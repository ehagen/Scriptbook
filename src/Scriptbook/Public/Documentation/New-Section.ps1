# experimental

Set-Alias -Name S -Value New-Section -Scope Global -Force -WhatIf:$false
Set-Alias -Name Section -Value New-Section -Scope Global -Force -WhatIf:$false
Set-Alias -Name Markdown -Value New-Section -Scope Global -Force -WhatIf:$false
function New-Section
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        $Text,
        [Switch]$Skip,
        [ScriptBlock] $Code
    
    )
    if ($Skip.IsPresent)
    {
        return
    }

    if ($PSCmdlet.ShouldProcess("New-Section"))
    {

        if ($Text -is [ScriptBlock])
        {
            Write-ScriptBlock $Text
        }
        else
        {
            Write-StringResult "$Text"
            Write-StringResult ''
            if ($null -eq $Code)
            {
                Throw "No section script block is provided. (Have you put the open curly brace on the next line?)"
            }
            Write-ScriptBlock $Code
        }
        Write-StringResult ''
    }
}
