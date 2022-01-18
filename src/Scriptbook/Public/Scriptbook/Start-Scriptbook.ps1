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

.EXAMPLE

Start-Scriptbook ./hallo-01.scriptbook.ps1

#>
function Global:Start-Scriptbook
{
    param(
        $File,
        $Actions,
        $Parameters,
        [switch]$Container,
        [HashTable]$ContainerOptions = @{}
    )

    if ($Container.IsPresent -or ($ContainerOptions.Count -gt 0) -and !$env:InScriptbookContainer)
    {
        Start-ScriptInContainer -File $Script:MyInvocation.ScriptName -Options $ContainerOptions -Parameters $Parameters
        return
    }
    else
    {
        . $File -Actions $Actions -Parameters $Parameters
    }
} 