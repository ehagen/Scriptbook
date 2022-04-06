<#
.SYNOPSIS
Starts a Scriptbook

.DESCRIPTION
Starts a Scriptbook

.PARAMETER File
Starts the workflow actions from Workflow file specified

.PARAMETER Actions
Contains the Action(s) to execute in sequential order. Overrides the order found in the script file and limits the actions to execute. Depended actions are always executed except when switch NoDepends is used. Use * to select all Actions in script. Use wildcard '*" to select actions by name with wildcard.

.PARAMETER Parameters
Parameters to pass to Workflow

.PARAMETER Container
Determines if workflow is run in container

.PARAMETER ContainerOptions
Determines the container options when running in a container. ContainerOptions.Image contains the container image used.

.PARAMETER Configure
Determines if workflow starts in configure mode --> Workflow configuration parameters are fetched from Console. Workflow is not executed.

.PARAMETER AsJob
Run Scriptbook in Powershell Job (Separate process)

.EXAMPLE

Start-Scriptbook ./hallo-01.scriptbook.ps1

#>
function Global:Start-Scriptbook
{
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        $File,
        $Actions,
        $Parameters,
        [switch]$Container,
        [HashTable]$ContainerOptions = @{},
        [switch]$Configure,
        [switch]$AsJob
    )

    if ($PSCmdlet.ShouldProcess($File))
    {
        # Let WhatsIf be handled downstream
    }

    Set-WorkflowInConfigureMode $Configure.IsPresent
    try
    {
        if ($Configure.IsPresent)
        {
            $AsJob = $false
        }

        if ($Container.IsPresent -or ($ContainerOptions.Count -gt 0) -and !$env:InScriptbookContainer)
        {
            Start-ScriptInContainer -File $Script:MyInvocation.ScriptName -Options $ContainerOptions -Parameters $Parameters -WhatIf:$WhatIfPreference
            return
        }
        else
        {
            $extraParams = @{}
            if ($Actions)
            {
                [void]$extraParams.Add('Actions', $Actions)
            }
            if ($Parameters)
            {
                [void]$extraParams.Add('Parameters', $Parameters)
            }
            if ($WhatIfPreference)
            {
                [void]$extraParams.Add('WhatIf', $true)
            }
            if ($AsJob.IsPresent)
            {
                Start-Job {
                    $file = $args[0]
                    $extraParams = $args[1]
                    . $file @extraParams
                } -ArgumentList $File, $extraParams | Wait-Job | Receive-Job
            }
            else
            {
                . $File @extraParams
            }
        }
    }
    finally
    {
        Set-WorkflowInConfigureMode $false
    }
}