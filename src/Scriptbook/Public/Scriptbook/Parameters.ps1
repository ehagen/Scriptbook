<#
.SYNOPSIS
Define Scriptbook Workflow Parameters

.DESCRIPTION
Define Scriptbook Workflow Parameters in PowerShell HashTable format and creates named PowerShell variable with HashTable as contents.

.PARAMETER Name
Name of created Parameters PowerShell variable, prevent naming conflicts by choosing unique or prefixed names

.PARAMETER Path
Location of Parameters values in json format

.PARAMETER Override
Allow the current Parameters to be over-written

.PARAMETER Code
HashTable with Parameters

.REMARK

.EXAMPLE

Parameters -Name 'DefaultParameters'  {
    @{
        Variable1 = 'one'
        Variable2 = 'two'
    }
}

# Access Context in Scriptbook like

Write-Host $Context.DefaultParameters.Variable1
Write-Host $Context.DefaultParameters.Variable2

or

$ctx = Get-WorkflowContext
Write-Host $ctx.DefaultParameters.Variable1
Write-Host $ctx.DefaultParameters.Variable2

# or via variable name

Write-Host $DefaultParameters.Variable1
Write-Host $DefaultParameters.Variable2

# Access Context in Scriptbook Action like

Write-Host $Context.DefaultParameters.Variable1
# or
Write-Host $Global:Context.DefaultParameters.Variable2
#or
Write-Host $Global:DefaultParameters.Variable2

# Update parameter in Scriptbook Action with
$Global:Context.DefaultParameters.Variable1 = 'newValue'
or
$Global:DefaultParameters.Variable1 = 'newValue'

#>
function Parameters
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Name,
        $Path,
        [switch]$Override,
        [Parameter(Position = 1)]
        [ScriptBlock]$Code
    )
    if ($WhatIfPreference) { Write-Host "What if: Performing the operation 'Parameters' on target '$Name'" }

    if ($Name -eq 'Parameters') { Throw "Invalid Parameters name found, '$Name' not allowed" }

    if (!($Override.IsPresent) -and (Get-Variable -Name Context -ErrorAction Ignore -Scope Global) -and $Global:Context.ContainsKey($Name))
    {
        Throw "Duplicate Parameters name found, use Override to replace current Parameters '$Name'"
    }

    if ($null -eq $Code -and !$Path)
    {
        Throw "No parameters script block is provided with HashTable. (Have you put the open curly brace on the next line?)"
    }
    try
    {
        $value = $null
        if ($Path -and (Test-Path $Path -ErrorAction Ignore))
        {
            $value = Read-ParameterValuesInternal -Path $Path
        }

        if ($null -eq $value)
        {
            $value = (Invoke-Command $Code)
            if (-not (($value -is [HashTable]) -or ($value -is [System.Collections.Specialized.OrderedDictionary])))
            {
                throw 'No HashTable found in Parameters' 
            }
        }

        # convert parameters HashTable to internal HashTable == context, we support different formats of parameters
        $internalValue = $value    

        # add Version variable if not found, init with 1.0.0
        if (!($internalValue.Contains('Version')))
        {
            $internalValue.Version = '1.0.0'
        }

        # create context
        if (!(Get-Variable -Name Context -ErrorAction Ignore -Scope Global))
        {
            Set-Variable -Name Context -Value @{ } -Scope Global -WhatIf:$false
        }
        $Global:Context."$Name" = $internalValue
        Set-Variable -Name $Name -Value $internalValue -Scope Global -WhatIf:$false

        if ($Global:ConfigurePreference)
        {
            Read-ParameterValuesFromHost -Name $Name -Notice 'Configure Scriptbook Parameters'
            if ($null -ne $Path)
            {
                Save-ParameterValues -Name $Name -Path $Path
            }
        }
    }
    catch
    {
        Write-Warning "Error setting '$Name' parameters to '$Code' $($_.Exception.Message)"
        Write-Warning "Only HashTable @{ Name = 'default'; Name2 = 'default2'} is allowed"        
    }
}