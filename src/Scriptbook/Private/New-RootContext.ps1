function New-RootContext
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [switch]$Soft
    )

    if ($PSCmdlet.ShouldProcess("New-RootContext"))
    {
        $actions = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,object]' -ArgumentList @([System.StringComparer]::InvariantCultureIgnoreCase)
        $actionSequence  = New-Object -TypeName 'System.Collections.ArrayList'
        $infos = New-Object -TypeName 'System.Collections.ArrayList'
        $notifications = New-Object -TypeName 'System.Collections.ArrayList'
        if ($Soft.IsPresent)
        {
            if ($Script:RootContext)
            {
                $actions = $Script:RootContext.Actions
                $actionSequence = $Script:RootContext.ActionSequence
                $infos = $Script:RootContext.Infos
                $notifications = $Script:RootContext.Notifications
            }
        }

        New-Object PSObject -Property @{
            Actions         = $actions
            ActionSequence  = $actionSequence
            IndentLevel     = -1
            NoLogging       = $false
            Id              = New-Guid
            InAction        = $false
            NestedActions   = New-Object -TypeName 'System.Collections.ArrayList'
            UniqueIdCounter = 1
            Infos           = $infos
            Notifications   = $notifications
        }    
    }
}

$Script:RootContext = New-RootContext -WhatIf:$false
