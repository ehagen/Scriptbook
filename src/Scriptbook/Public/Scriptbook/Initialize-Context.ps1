<#
.SYNOPSIS
Define Scriptbook Workflow Context

.DESCRIPTION
Define Scriptbook Workflow Context in PowerShell HashTable format and creates named PowerShell variable with HasTable as contents.

.PARAMETER Name
Name of created PowerShell variable, defaults to DefaultContext

.PARAMETER Path


.PARAMETER Code
HashTable with Context variables

.REMARK

.EXAMPLE

WorkflowContext -Name 'DefaultContext'  {
    @{
        Variable1 = 'one'
        Variable2 = 'two'
    }
}

# Access Context in Scriptbook with

Write-Host $DefaultContext.Variable1
Write-Host $DefaultContext.Variable2

# Access Context in Scriptbook Action with

Write-Host $DefaultContext.Variable1
# or
Write-Host $Script:DefaultContext.Variable2

# Update Context in Scriptbook Action with
$Script:DefaultContext.Variable1 = 'newValue'

#>
<#
TODO Add Save-Context -Name 'DefaultContext' -Path './MyContext.json'
TODO Add Read-ContextFromHost -Name 'DefaultContext' / Scriptdialog...
TODO Add Checkpoint-Context -Name 'DefaultContext' -Path './MyContext.json'
TODO Add Restore-Context -Name 'DefaultContext' -Path './MyContext.json'
TODO Add Get-ContextVariable -Context 'DefaultContext' -Name 'Item.Name'
TODO Add Set-ContextVariable -Context 'DefaultContext' -Name 'Product.Item.Name

WorkflowContext -Path './DefaultContext.json' {
    @{
        Azure   = @{
            SubscriptionId       = @{
                Default     = '000-000-000-000-000'
                Description = 'Subscription'
                Type        = 'string'
            }
            SubscriptionName     = @{
                Default     = ''
                Description = 'SubscriptionName'
                Type        = 'string'
                Calculated  = $true
            }
            TenantId             = @{
                Default     = ''
                Description = 'TenantId'
                Type        = 'string'
            }
            ServicePrincipalId   = @{
                Default     = ''
                Description = 'ServicePrincipalId'
                Type        = 'string'
            }
            ServicePrincipalKey  = @{
                Default     = ''
                Description = 'ServicePrincipalKey'
                Type        = 'SecureString'
                Calculated  = $true
            }
            ResourceGroupPrefix  = @{
                Default     = ''
                Description = 'ResourceGroupPrefix'
                Type        = 'string'
            }
            ResourceGroupPostfix = @{
                Default     = ''
                Description = 'ResourceGroupPostfix'
                Type        = 'string'
                MinLength   = 1
                MaxLength   = 5
            }
            NodeCount            = @{
                Default     = 1
                Description = 'NodeCount'
                Type        = 'int'
                MinValue    = 0
                MaxValue    = 10
            }
            NodeSku              = @{
                Default       = 'free'
                Description   = 'NodeSku'
                Type          = 'string'
                AllowedValues = @('Free', 'Minimal', 'Maximal')
            }
        }
        Samples = @{
            Url        = ''
            Database = ''
        }
    }
}

#>
function Initialize-Context
{
    [CmdletBinding()]
    param(
        $Name,
        $Path,
        [switch]$Global,
        [Parameter(Position = 1)]
        [ScriptBlock]$Code
    )
    if ($null -eq $Code)
    {
        Throw "No context script block is provided with HashTable. (Have you put the open curly brace on the next line?)"
    }
    try
    {
        $scope = if ($Global.IsPresent) { 'Global' } else { 'Script' }
        $value = (Invoke-Command $Code)
        if (!($value -is [HashTable])) { throw 'No HashTable found in Context' }

        # convert parameters HashTable to internal HashTable, we support different formats of parameters
        $internalValue = $value

        if ($Path -and (Test-Path $Path -ErrorAction Ignore))
        {
            # TODO Load Context
            # load from json secure...
        }

        # add Version variable if not found, init with 1.0.0
        if (!($internalValue.ContainsKey('Version')))
        {
            $internalValue.Version = '1.0.0'
        }
        Set-Variable -Name $Name -Value $internalValue -Scope $scope
    }
    catch
    {
        Write-Warning "Error setting '$Name' context to '$Code' $($_.Exception.Message)"
        Write-Warning "Only HashTable @{ Name = 'default'; Name2 = 'default2'} is allowed"
    }
}