<#
.SYNOPSIS
Define Scriptbook Workflow variables

.DESCRIPTION
Define Scriptbook Workflow variables in PowerShell HashTable format and creates named PowerShell variable with HasTable as contents.

.PARAMETER Name
Name of created Variables PowerShell HashTable variable

.PARAMETER Override
Allow the current Variables to be over-written

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

Write-Host $Context.Samples.Variable1
Write-Host $Context.Samples.Variable2

or

$ctx = Get-WorkflowContext
Write-Host $ctx.Samples.Variable1
Write-Host $ctx.Samples.Variable2

# Access variables in Scriptbook Action with

Write-Host $Context.Samples.Variable1
# or
Write-Host $Global:Context.Samples.Variable2

# Update variables in Scriptbook Action with
$Global:Context.Samples.Variable1 = 'newValue'

#>
function Variables
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Name,
        [switch]$Override,
        [Parameter(Position = 1)]
        [ScriptBlock]$Code
    )
    if ($Name -eq 'Variables') { Throw "Invalid Variables name found, '$Name' not allowed" }

    if ( !($Override.IsPresent) -and (Get-Variable -Name Context -ErrorAction Ignore -Scope Global) -and $Global:Context.ContainsKey($Name))
    {
        Throw "Duplicate Variables name found, use Override to replace current Variables '$Name'"
    }

    if ($null -eq $Code)
    {
        Throw "No variables script block is provided with HashTable. (Have you put the open curly brace on the next line?)"
    }
    try
    {   
        $value = (Invoke-Command $Code)
        if (!($value -is [HashTable])) { throw 'No HashTable found in Variables' }

        # create context
        if (!(Get-Variable -Name Context -ErrorAction Ignore -Scope Global))
        {
            Set-Variable -Name Context -Value @{ } -Scope Global
        }

        $Global:Context."$Name" = $value
        Set-Variable -Name $Name -Value $value -Scope Global
    }
    catch
    {
        Write-Warning "Error setting '$Name' variable to '$Code' $($_.Exception.Message)"
        Write-Warning "Only HashTable @{ Name = 'default'; Name2 = 'default2'} is allowed"
        Throw
    }
}