<#
.SYNOPSIS
Registers and validates a new Action for Workflow.

.DESCRIPTION
Registers and validates a new Action for Workflow. Action is recorded but not executed until the workflow starts.

.PARAMETER Name
.PARAMETER IsGroup
.PARAMETER Tag
.PARAMETER Depends
.PARAMETER Parameters
.PARAMETER AsJob
.PARAMETER If
.PARAMETER Description
.PARAMETER Disabled
.PARAMETER TypeName
.PARAMETER NextAction
.PARAMETER For
.PARAMETER Parallel
.PARAMETER Container
.PARAMETER ContainerOptions
.PARAMETER Session
.PARAMETER Isolated
.PARAMETER Unique
.PARAMETER RequiredVariables
.PARAMETER Comment
.PARAMETER SuppressOutput
.PARAMETER Code

.EXAMPLE
Register-Action

#>
function Register-Action
{
    param(
        [Parameter(Mandatory = $true, Position = 0)][string][ValidateNotNullOrEmpty()]$Name,
        [switch]$IsGroup,
        [string[]] $Tag = @(),
        [string[]] $Depends = @(),
        [AllowNull()]
        $Parameters = @{},
        [AllowNull()]
        [switch]$AsJob,
        [ScriptBlock] $If,
        [String]$Description,
        [bool]$Disabled = $false,
        [ValidateNotNullOrEmpty()]
        [string]$TypeName,
        [string]$NextAction,
        [ScriptBlock] $For,
        [switch]$Parallel,
        [switch]$Container,
        [HashTable]$ContainerOptions = @{},
        [AllowNull()]
        $Session,
        [switch]$Isolated,
        [switch]$Unique,
        [string[]]$RequiredVariables,
        [string]$Comment,
        [switch]$SuppressOutput,
        [ScriptBlock] $Code
    )

    $ctx = Get-RootContext
    $lName = $Name -replace 'Invoke-', ''
    if ($Unique.IsPresent)
    {
        $ctx.UniqueIdCounter += 1
        $lName = "$lName-$("{0:00}" -f $ctx.UniqueIdCounter)"
    }

    # Get Comments
    $text = $null
    if ($Comment)
    {
        $text = $Comment + [System.Environment]::NewLine
    }
    $text += Get-CommentFromCode -ScriptBlock $Code

    $lAction = New-Object PSObject -Property @{
        Code              = $Code
        Name              = "Action-$lName"
        DisplayName       = $lName
        Id                = (New-Guid)
        Tags              = $Tag
        ErrorAction       = $ErrorActionPreference
        Depends           = $Depends
        Parameters        = $Parameters
        AsJob             = [bool]$AsJob.IsPresent
        If                = $If
        Description       = $Description
        IsGroup           = $IsGroup.IsPresent
        Disabled          = $Disabled
        TypeName          = $TypeName
        NextAction        = $NextAction
        For               = $For
        Parallel          = $Parallel.IsPresent
        Container         = $Container.IsPresent
        ContainerOptions  = $ContainerOptions
        Session           = $Session
        Isolated          = $Isolated
        RequiredVariables = $RequiredVariables
        Comment           = ($text | Out-String)
        SuppressOutput    = $SuppressOutput
    }
    if ($ctx.Actions.ContainsKey($lAction.Name))
    {
        $displayName = $lAction.Name.Replace('Action-', '').Replace('Invoke-', '')
        Throw "Duplicate Name '$displayName' found, use unique name for each action/step/job/flow"
    }

    # add
    if ($ctx.InAction)
    {
        [void]$ctx.NestedActions.Add($lAction)
    }
    else
    {
        [void]$ctx.ActionSequence.Add($lAction)
    }
    [void]$ctx.Actions.Add($lAction.Name, $lAction)
    Set-Alias -Name $Name -Value Action -Scope Global -Force -ErrorAction Ignore -WhatIf:$false
}