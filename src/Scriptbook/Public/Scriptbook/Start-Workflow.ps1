<#
.SYNOPSIS
Starts a Workflow defined by Workflow Actions or PowerShell Functions

.DESCRIPTION
Starts a Workflow defined by Workflow Actions or PowerShell Functions. Each action scriptblock is executed once in the order given by the workflow. Use the workflow report to see the final execution order/stack. The workflow is 
executed by the order of actions found in the script Workflow file or by the actions parameter. When actions have dependencies they are resolved at run-time and executed according the dependency graph.

To influence the execution of actions use the action 'If' property

.PARAMETER Actions
Contains the Action(s) to execute in sequential order. Overrides the order found in the script file and limits the actions to execute. Depended actions are always executed except when switch NoDepends is used.

.PARAMETER Parameters
Parameters to pass to Workflow

.PARAMETER Name
Set the name of the workflow

.PARAMETER Tag
Set the workflow Tag(s)

.PARAMETER Location
Set current directory to location specified

.PARAMETER File
Starts the workflow actions from Workflow file specified

.PARAMETER NoReport
Disables the action report at the end of the workflow

.PARAMETER NoLogging
Disables the start/finish action logging

.PARAMETER NoDepends
Disables the calling of dependent actions. Allows for executing one specific Action

.PARAMETER Test
Starts workflow in 'TestWorkflow' Mode. No actions are executed except Test Actions

.PARAMETER Transcript
Creates a record of PowerShell Workflow session and saves this to a file.

.PARAMETER Container
Determines if workflow is run in container

.PARAMETER ContainerOptions
Determines the container options when running in a container. ContainerOptions.Image contains the container image used.

.PARAMETER Parallel
Determines if the workflow actions are executed in parallel. !Experimental

.PARAMETER WhatIf / Plan
Shows the Workflow execution plan

.PARAMETER Documentation
Shows the Workflow documentation and execution plan

.EXAMPLE
Start-WorkFlow

.REMARKS
- Workflow File not working yet --> Include ?

.NOTES
Workflow
Workflow is modeled as a set of actions invoked in some sequence where the completion of one action flows directly into the start of the next action

#>
Set-Alias -Name Start-Flow -Value Start-Workflow -Scope Global -Force -WhatIf:$false
Set-Alias -Name Start-Saga -Value Start-Workflow -Scope Global -Force -WhatIf:$false
Set-Alias -Name Start-Pipeline -Value Start-Workflow -Scope Global -Force -WhatIf:$false
function Start-Workflow
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0)]
        [AllowNull()]
        [array][alias('Actions', 'Steps', 'Jobs', 'Activities')]$WorkflowActions,
        [AllowNull()]
        [alias('Parameters')]
        $WorkflowParameters,
        [ValidateNotNullOrEmpty()]
        [alias('Name')]
        [string]$WorkflowName = '.',
        [String[]] $Tag = @(),        
        [alias('Location')]
        [string]$WorkflowLocation,
        [alias('File')]
        [string]$WorkflowFile,
        [switch]$NoReport,
        [switch]$NoLogging,
        [switch]$NoDepends,
        [alias('Test')]
        [switch]$TestWorkflow,
        [alias('Transcript')]
        [switch]$WorkflowTranscript,
        [alias('Container')]
        [switch]$WorkflowContainer,
        [alias('ContainerOptions')]
        [HashTable]$WorkflowContainerOptions = @{},
        [alias('Parallel')]
        [switch]$WorkflowParallel,
        [switch]$Plan,
        [switch]$Documentation
    )

    if ($WorkflowContainer.IsPresent -and !$env:InScriptbookContainer)
    {
        # TODO !!EH supply all the parameters of the script caller?
        Start-ScriptInContainer -File $Script:MyInvocation.ScriptName -Options $WorkflowContainerOptions # -Parameters ([Hashtable]$Global:MyInvocation.MyCommand.WorkflowParameters)
        return;
    }

    $Global:LastExitCode = 0
    $script:InvokedCommands = @()
    $script:InvokedCommandsResult = @()
    $workflowErrorAction = $ErrorActionPreference
    if ($WorkflowLocation)
    {
        $Script:WorkflowLocation = $WorkflowLocation
    }
    else
    {
        $Script:WorkflowLocation = Get-Location
    }
    $ctx = Get-RootContext
    $ctx.NoLogging = $NoLogging.IsPresent
    $isWhatIf = -not $PSCmdlet.ShouldProcess($WorkflowName, "Workflow")
    if ($Plan.IsPresent -or $Documentation.IsPresent)
    {
        $WhatIfPreference = $true
        $isWhatIf = $WhatIfPreference
    }

    $scriptName = $Script:MyInvocation.ScriptName
    if ([string]::IsNullOrEmpty($scriptName))
    {
        $scriptName = Join-Path $PSScriptRoot 'Scriptbook.ps1'
    }

    $hasErrors = $false
    $workflowStopwatch = [System.Diagnostics.Stopwatch]::StartNew();
    Write-ScriptLog @{action = "Workflow-Started"; param = $WorkflowActions; } -AsWorkflow
    $currentLocation = Get-Location
    try
    {
        if ($WorkflowTranscript.IsPresent)
        {
            Start-Transcript -Path "$scriptName.log" -Append -Force -IncludeInvocationHeader
        }
    
        try
        {
            if ($WorkflowFile -and (Test-Path $WorkflowFile) )
            {
                . $WorkflowFile
            }
            try
            {
                if (Global:Invoke-BeforeWorkflow -Commands $WorkflowActions)
                {
                    try
                    {
                        if ($null -ne $WorkflowActions -and ($WorkflowActions.count -gt 0) )
                        {
                            foreach ($action in $WorkflowActions)
                            {
                                if (!($action.StartsWith('!')))
                                {
                                    Invoke-PerformIfDefined -Command "Invoke-$($action.Replace('Invoke-', ''))" -ThrowError $true -ActionParameters $WorkflowParameters -NoDepends:$NoDepends.IsPresent -Test:$TestWorkflow.IsPresent -WhatIf:$isWhatIf
                                }
                            }
                        }
                        else
                        {
                            Invoke-ActionSequence -Actions $ctx.ActionSequence -ThrowError $true -Test:$TestWorkflow.IsPresent -WhatIf:$isWhatIf -Parallel:$WorkflowParallel.IsPresent
                        }
                    }
                    finally
                    {
                        Invoke-ActionAlways -Actions $ctx.ActionSequence -ThrowError $true -Test:$TestWorkflow.IsPresent -WhatIf:$isWhatIf -Parallel:$WorkflowParallel.IsPresent
                    }
                }
            }
            finally
            {
                Global:Invoke-AfterWorkflow -Commands $WorkflowActions
            }
        }
        catch
        {
            if ($workflowErrorAction -eq 'Continue')
            {
                Write-ExceptionMessage $_ -TraceLineCnt 15
            }
            elseif ($workflowErrorAction -notin 'Ignore', 'SilentlyContinue')
            {
                $hasErrors = $true
                Write-ExceptionMessage $_ -TraceLineCnt 15
                Global:Write-OnLogException -Exception $_.Exception
                Global:Invoke-AfterWorkflow -Commands $WorkflowActions -ErrorRecord $_ | Out-Null    
                Throw
            }
        }
        if ($Global:LastExitCode -ne 0) 
        {
            Write-Warning "Workflow: Unsuspected LastExitCode found from native commands/executable: $($Global:LastExitCode), check logging." 
            $Global:LastExitCode = 0;
        }        
    }
    finally
    {
        Set-Location $currentLocation
        $workflowStopwatch.Stop()
        
        if (!$NoReport.IsPresent)
        {            
            #TODO !!EH: Fix issue ansi escape sequences and Format-Table (invalid sizing)
            $script:InvokedCommandsResult | ForEach-Object { $hasErrors = if ($null -ne $_.Exception) { $true } else { $hasErrors }; <#if ($_.Exception) { $_.Name = "`e[37;41m$($_.Name)`e[0m" } else { $_.Name = "`e[00;00m$($_.Name)`e[0m" }; #> }
            if ($workflowErrorAction -in 'Ignore', 'SilentlyContinue')
            {
                $hasErrors = $false
            }

            if ($TestWorkflow.IsPresent)
            {
                $reportTitle = 'Workflow (Test) Report'
            }
            elseif ($Documentation.IsPresent)
            {
                $reportTitle = "Workflow Documentation"
            }
            elseif ($isWhatIf)
            {
                $reportTitle = "Workflow ($(if ($Plan.IsPresent) { 'Plan' } else { 'WhatIf' })) Report"
            }
            else
            {
                $reportTitle = 'Workflow Report'
            }

            Write-ScriptLog @{action = "Workflow-Finished"; } -AsWorkflow -AsError:$hasErrors

            if ($Documentation.IsPresent)
            {
                Write-Experimental "Workflow Documentation"
            }

            Write-Info ''.PadRight(78, '-')
            if ($hasErrors)
            {
                Write-Info "$reportTitle '$WorkflowName' with errors $((Get-Date).ToString('s'))" -ForegroundColor White -BackgroundColor Red
            }
            else
            {
                Write-Info "$reportTitle '$WorkflowName' $((Get-Date).ToString('s'))"
            }
            if ($Tag)
            {
                Write-Info $Tag
            }

            Write-Info ''.PadRight(78, '-')

            $script:InvokedCommandsResult | ForEach-Object { if ($_.Exception) { $_.Exception = $_.Exception.Message } }
            $script:InvokedCommandsResult | ForEach-Object { $_.Name = ''.PadLeft(($_.Indent) + 1, '-') + $_.Name }

            if ($Documentation.IsPresent)
            {
                if (Test-Path $scriptName)
                {
                    $text = Get-CommentFromCode -File $scriptName -First 1
                    Write-Info ($text | Out-String)
                    Write-Info ''.PadRight(78, '-')
                }

                $ctx = Get-RootContext
                if ($ctx.Infos.Count -gt 0)
                {
                    foreach ($info in $ctx.Infos)
                    {
                        Write-Info ($info | Out-String)
                    }
                    Write-Info ''.PadRight(78, '-')
                }

                $script:InvokedCommandsResult | ForEach-Object { 
                    $item = [PSCustomObject]$_
                    Write-Info "Action `e[0;36m$($item.Name)`e[0m" -ForegroundColor Magenta
                    Write-Info ''.PadRight(78, '-')
                    if (![string]::IsNullOrEmpty($item.Comment))
                    {
                        Write-Info "$($item.Comment)"
                    }
                    else
                    {
                        Write-Info '<no documentation>'
                    }
                    Write-Info ''.PadRight(78, '-')
                }
                $script:InvokedCommandsResult += @{ Name = ''; Duration = '================'; }
                Write-Info ''
                Write-Info "Workflow Sequence" -ForegroundColor Magenta
                $script:InvokedCommandsResult += @{ Name = 'Total'; Duration = $workflowStopwatch.Elapsed; }
    
                $script:InvokedCommandsResult | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize -Property Name, Duration | Out-String | Write-Info
            }
            else
            {
                $script:InvokedCommandsResult += @{ Name = ''; Duration = '================'; }
                $script:InvokedCommandsResult += @{ Name = 'Total'; Duration = $workflowStopwatch.Elapsed; }
    
                $script:InvokedCommandsResult | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize Name, Duration, Exception, @{Label = 'Output' ; Expression = { $_.ReturnValue } } | Out-String | Write-Info
            }
            Write-Info ''.PadRight(78, '-')
        }

        if ($WorkflowTranscript.IsPresent)
        {
            Stop-Transcript
        }
                
        Reset-Workflow -WhatIf:$false -Soft
    }

}