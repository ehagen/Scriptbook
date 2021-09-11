<#
.SYNOPSIS
Imports one or more Actions from File with parent defined parameters

.DESCRIPTION
Imports one or more Actions from File with parent defined parameters. Use this in your startup scripts.

.PARAMETER File
Name of the File

.EXAMPLE
Script File with One Action (myAction.ps1):

param(
    [ValidateNotNullOrEmpty()]
    $MyParam1
)

Action -Name MyAction {
    Write-Info "Script param value: $MyParam1"
    Write-Info 'MyAction'
}

Startup Script (startup.ps1):

param(
    $MyParam1 = 'Hello'
)

Set-Location $PSScriptRoot
Import-Module Scriptbook
Import-Action ./myAction.ps1 #-Context $ExecutionContext

Start-Workflow

.EXAMPLE
Alternative is in startup script:

$parameters = Get-BoundParametersWithDefaultValue
. ./myAction.ps1 @parameters
#>
Set-Alias -Name Import-Test -Value Import-Action -Scope Global -Force -WhatIf:$false
Set-Alias -Name Import-Step -Value Import-Action -Scope Global -Force -WhatIf:$false
#Set-Alias -Name Import-Activity -Value Import-Action -Scope Global -Force -WhatIf:$false
#Set-Alias -Name Import-Job -Value Import-Action -Scope Global -Force -WhatIf:$false
#Set-Alias -Name Import-Stage -Value Import-Action -Scope Global -Force -WhatIf:$false
#Set-Alias -Name Import-Flow -Value Import-Action -Scope Global -Force -WhatIf:$false
function Import-Action
{
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $File,
        #$Context,
        $Invocation = $Global:MyInvocation
    )
    $parameters = Get-BoundParametersWithDefaultValue $Invocation
    $localVars = @{}
    Get-Variable -Scope Local | ForEach-Object { [void]$localVars.Add($_.Name, $null) }

    Get-ChildItem $File | Sort-Object -Property FullName | ForEach-Object {
        $parameterList = (Get-Command -Name $_.FullName).Parameters;
        $parameterSelector = $parameters.Clone()
        foreach ($pm in $parameterSelector.Keys)
        {
            if (!$parameterList.ContainsKey($pm)) {$parameters.Remove($pm)}
        }
        . $($_.FullName) @parameters        
    }

    $newLocalVars = Get-Variable -Scope Local
    foreach ($var in $newLocalVars.GetEnumerator())
    {
        if (!$localVars.ContainsKey($var.Name))
        {
            Set-Variable -Scope Global -Name $var.Name -Value $var.Value -Force -Visibility Public
        }
    }
}

<#
    Scoping Experiments. Unable to run import in Caller Scope, local vars missing --> copy local vars for now

    # in module scope
    $m = Get-Module Scriptbook
    & $m {
        param($File, $Parameters);
        . ./$File @Parameters
    } -File $File -Parameters $parameters
    return

    # in current scope
    . ./$File @parameters

    # in current scope
    Invoke-Command { param($File, $Parameters); . ./$File @parameters } -ArgumentList $File, $parameters #-NoNewScope 

    # in caller context scope
    $module = [PSModuleInfo]::New($true)
    $module.SessionState = $Context.SessionState
    & {
        param($File, $Parameters);
        . ./$File @Parameters
    } -File $File -Parameters $parameters
    
    # in caller context scope
    . $module ./$File @parameters

    # in context scope
    $sb = { . ./configure.actions.ps1 -OrganizationPrefix 'td' -Environments @('dev', 'tst') -SubscriptionId '45f8a4be-d177-489e-8ec2-e1a53d87aadc' }
    $Context.InvokeCommand.InvokeScript($Context.SessionState, $sb, @())
#>