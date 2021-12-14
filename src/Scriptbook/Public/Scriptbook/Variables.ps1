<#
.SYNOPSIS
Define Scriptbook Workflow variables

.DESCRIPTION
Define Scriptbook Workflow variables in PowerShell HashTable format and creates named PowerShell variable with HasTable as contents.

.PARAMETER Name
Name of created PowerShell HashTable variable

.PARAMETER Context
Workflow Context to add/merge Variables

.PARAMETER Append
Allows only to append to created PowerShell HashTable variable. If exists error is generated otherwise contents is merged.

.PARAMETER Code
HashTable with variables

.REMARK

.EXAMPLE

Variables -Name Samples {
    @{
        Variable1 = 'one'
        Variable2 = 'two'
    }
}

# Access variables in Scriptbook with

Write-Host $Samples.Variable1
Write-Host $Samples.Variable2

# Access variables in Scriptbook Action with

Write-Host $Samples.Variable1
# or
Write-Host $Script:Samples.Variable2

# Update variables in Scriptbook Action with
$Script:Samples.Variable1 = 'newValue'

#>
function Variables
{
    [CmdletBinding()]
    param(
        $Name,
        $WorkflowContext,
        [switch]$Append,
        [switch]$Global,
        [Parameter(Position = 1)]
        [ScriptBlock]$Code
    )
    if ($null -eq $Code)
    {
        Throw "No variables script block is provided with HashTable. (Have you put the open curly brace on the next line?)"
    }
    try
    {   
        $scope = if ($Global.IsPresent) { 'Global' } else { 'Script' }
        $value = (Invoke-Command $Code)
        if (!($value -is [HashTable])) { throw 'No HashTable found in Variables' }

        if ($WorkflowContext)
        {
            throw 'Not implemented'
        }
        else
        {
            if ((Get-Variable -Name $Name -ErrorAction Ignore -Scope $scope) -and $Append.IsPresent)
            {
                Write-Warning "Variable '$Name' already defined, cannot be appended"
            }
            else
            {
                Set-Variable -Name $Name -Value $value -Scope $scope
            }
        }
    }
    catch
    {
        Write-Warning "Error setting '$Name' variable to '$Code' $($_.Exception.Message)"
        Write-Warning "Only HashTable @{ Name = 'default'; Name2 = 'default2'} is allowed"
    }
}