<#
.SYNOPSIS
Defines an action executed by Workflow

.DESCRIPTION
Defines an action executed by Workflow. At least one action is required by workflow. Actions are executed in workflow sequence and/or their dependency order. By using the If condition an action can be excluded from the workflow execution.
An action scriptblock can be executed multiple times by using the For expression. Default the action runs in the workflow of the current Powershell session. Optionally action scriptblock can be executed in a Docker Container or a Remote Powershell Session.

Action in Docker Container
- requires docker installed on current machine

Action in Remote Powershell Session
- requires valid PSSession with access to remote host (PS Remoting or SSH Remoting)

.PARAMETER Name
Set the Name of the action

.PARAMETER Tag
Set the tag(s) array of the action

.PARAMETER Depends
Set list of dependent actions. Dependent actions are executed before this action in the order of the workflow dependency graph

.PARAMETER Parameters
Parameters to pass to Workflow

.PARAMETER AsJob
Run action in Powershell Job (Separate process)

.PARAMETER Description
Contains description of Action

.PARAMETER If
Boolean expression to determine if action if executed, like { $value -eq $true }

.PARAMETER Disabled
Determines if action is disabled, exempt from workflow

.PARAMETER NextAction
Next Action to execute when action is finished

.PARAMETER For
Sequence expression for setting the number of executing the same action scriptblock, like { 1..10 } or { 'hello','and','goodby' }

.PARAMETER Parallel
Determines if the action scriptblock is executed in parallel. Used by the For expression when running in Powershell 7+ and when used with switch -AsJob

.PARAMETER Container
Determines if action is run in container

.PARAMETER ContainerOptions
Determines the container options when running action in a container. ContainerOptions.Image contains the container image used.

.PARAMETER Session
Contains the remote session object to run the action scriptblock on remote host via Powershell Remoting

.PARAMETER Isolated
Determines when if user ps-modules, scriptbook module and script/workflow are copied/used by (remote) container or remote-session.

.PARAMETER Unique
Always generates unique name for Action. Prevent collision with required unique Action names

.PARAMETER RequiredVariables
Enables checking for required variables before action starts. If variable not available in global, script or local scope action fails.

.PARAMETER Comment
Add Comment to Action for documentation purpose

.PARAMETER SuppressOutput
if present suppresses write/output of Action return value or output stream to console

.PARAMETER Always
Determines if Action is Always executed regardless of any error in other actions, or missing in dependency tree, or missing in Workflow Actions

.PARAMETER NoSequence
Determines if Action is executed when sequential/linear Workflow is executed

.PARAMETER Multiple
Determines if Action can be called multiple times, default Action can only be called once

.PARAMETER Code
Contains the action code/scriptblock to execute when action is enabled (default) 

.EXAMPLE

.NOTES

#>
Set-Alias -Name Test -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False
Set-Alias -Name Tests -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False
Set-Alias -Name Step -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False
Set-Alias -Name Activity -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False
Set-Alias -Name Job -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False
Set-Alias -Name Chore -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False
Set-Alias -Name Stage -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False
Set-Alias -Name Override -Value Action -WhatIf:$false -Confirm:$False
Set-Alias -Name Setup -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False
Set-Alias -Name Teardown -Value Action -Scope Global -Force -WhatIf:$false -Confirm:$False

function Action
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSupportsShouldProcess", "")]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string] $Name,
        [String[]] $Tag = @(),
        [String[]] $Depends = @(),
        [HashTable]$Parameters = @{},
        [Switch]$AsJob,
        [ValidateNotNullOrEmpty()]
        [String]$Description,
        [ScriptBlock] $If,
        [alias('Skip')][switch] $Disabled,
        [ValidateNotNullOrEmpty()]
        [string][alias('Next')] $NextAction,
        [ScriptBlock] $For,
        [switch] $Parallel,
        [switch] $Container,
        [HashTable] $ContainerOptions = @{},
        [AllowNull()]
        $Session,
        [switch]$Isolated,
        [switch]$Unique,
        [ValidateNotNull()]
        [string[]]$RequiredVariables = @(),
        [string]$Comment,
        [switch]$SuppressOutput,
        [switch]$Always,
        [switch]$NoSequence,
        [switch]$WhatIf,
        [switch]$Confirm,
        [switch]$Multiple,
        [Parameter(Position = 1)]
        [ScriptBlock] $Code
    )

    $lName = $Name -replace 'Invoke-', ''
    if ($PSCmdlet.MyInvocation.InvocationName -eq 'Test')
    {
        $Name = "Test.$Name"
        $lName = $Name
    }
    if ($lName -ne 'Default' -and $lName -ne '.' )
    {
        if ($null -eq $Code)
        {
            if ([string]::IsNullOrEmpty($Name))
            {
                Throw "No code script block is provided and Name property is mandatory. (Have you put the open curly brace on the next line?)"
            }
            else
            {
                $n = $Name.Split("`n")
                if ($n.Count -gt 1)
                {
                    Throw "No Name provide for Action, Name is required, found scriptblock { $Name } instead."
                }
                else
                {
                    Throw "No code script block is provided for '$Name'. (Have you put the open curly brace on the next line?)"
                }
            }
        }
        $typeName = $PSCmdlet.MyInvocation.InvocationName
        $uniqueOption = $Unique.IsPresent
        $alwaysOption = $Always.IsPresent
        $errorOption       = $ErrorActionPreference
        if ($typeName -eq 'Teardown')
        {
            $alwaysOption = $true
        }
        elseif ($typeName -eq 'Tests')
        {
            $errorOption = 'Continue'
        }
        $options = @{
            Name              = $Name
            Tag               = $Tag
            Depends           = $Depends
            Parameters        = $Parameters
            ErrorAction       = $errorOption
            AsJob             = $AsJob.IsPresent
            If                = $If
            Description       = $Description
            Code              = $Code
            Disabled          = $Disabled.IsPresent
            TypeName          = $typeName
            NextAction        = $NextAction
            For               = $For
            Parallel          = $Parallel.IsPresent
            Container         = $Container.IsPresent
            ContainerOptions  = $ContainerOptions
            Session           = $Session
            Isolated          = $Isolated.IsPresent
            Unique            = $uniqueOption
            RequiredVariables = $RequiredVariables
            Comment           = $Comment
            SuppressOutput    = $SuppressOutput.IsPresent
            Always            = $alwaysOption
            NoSequence        = $NoSequence.IsPresent
            WhatIf            = $WhatIf.IsPresent
            Confirm           = $Confirm.IsPresent
            Multiple          = $Multiple.IsPresent            
        }
        Register-Action @options
    }

    # Start build-in Action: Start Workflow
    if ($lName -eq 'Default' -or $lName -eq '.')
    {
        Start-Workflow -Actions $Depends -Parameters $Parameters -Location (Get-Location)
    }
}
