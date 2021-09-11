<#
.SYNOPSIS
Use workflow inline

.DESCRIPTION
Use workflow inline and aliases Flow and Pipeline

.REMARK
See parameters of Start-Workflow

.EXAMPLE

Use-Workflow -Name Workflow1 {
    Action Hello {
        Write-Info "Hello from Workflow1 1"
    }

    Action GoodBy {
        Write-Info "GoodBy from Workflow1 1"
    }
}

#>
Set-Alias -Name Flow -Value Use-Workflow -Scope Global -Force -WhatIf:$false
Set-Alias -Name Pipeline -Value Use-Workflow -Scope Global -Force -WhatIf:$false
function Use-Workflow
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [alias('Name')]
        [string]$WorkflowName,
        [array][alias('a', 'Action', 'Actions')]$WorkflowActions,
        [alias('Parameters')]
        $WorkflowParameters,
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
        [Parameter(Position = 1)]
        [alias('Code')]
        [ScriptBlock] $WorkflowCode
    )

    $invokeErrorAction = $ErrorActionPreference

    if ($null -eq $WorkflowCode)
    {
        Throw "No workflow code script block is provided and Name property is mandatory. (Have you put the open curly brace on the next line?)"
    }

    try 
    {
        & $WorkflowCode $WorkflowParameters
    }
    catch
    {        
        if ($invokeErrorAction -eq 'Continue')
        {
            Write-ScriptLog $_.Exception.Message -AsError
        }
        elseif ($invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
        {
            Throw
        }
    }

    # force clear context on start each workflow
    Start-Workflow -Actions $WorkflowActions -Parameters $WorkflowParameters -Name $WorkflowName -Tag $Tag -Location $WorkflowLocation -WorkflowFile $WorkflowFile -NoReport:$NoReport.IsPresent -NoLogging:$NoLogging.IsPresent -NoDepends:$NoDepends.IsPresent -Test:$TestWorkflow.IsPresent
    Reset-Workflow -WhatIf:$false
}