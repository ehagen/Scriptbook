<#
.SYNOPSIS
Add Workflow Notification

.DESCRIPTION
Add Notifications to Workflow. Notification are shown on console when Workflow is finished. A way to emphasis Workflow output

.PARAMETER Message
Notification Message

.PARAMETER Decoration
Determines if notification is just decorative

.PARAMETER Target
Determines target of Notification, just console for now.

#>
function Add-WorkflowNotification([ValidateNotNullOrEmpty()][string]$Message, [switch]$Decoration, $Target = 'Console')
{
    $ctx = Get-RootContext
    [void]$ctx.Notifications.Add($Message)
}
