<#
.SYNOPSIS
Returns Action runtime state 

.DESCRIPTION
Returns Action runtime state. Each Action has some runtime state like return-value or exception

.PARAMETER Name
Name of the Action

#>
Set-Alias -Name Get-ActionOutput -Value Get-ActionReturnValue -Scope Global -Force -WhatIf:$false
Set-Alias -Name Get-ActionOutputValue -Value Get-ActionReturnValue -Scope Global -Force -WhatIf:$false
function Get-ActionState
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    param($Name)

    $ctx = Get-RootContext
    if ($ctx.Actions.Count -eq 0)
    {
        throw "No actions defined or workflow finished in Get-ActionState"
    }

    $returnValue = $null
    $action = $ctx.Actions["Action-$($Name.Replace('Action-',''))"]
    if ($action)
    {
        $script:InvokedCommandsResult | ForEach-Object { 
            if ($_.Command -eq $action.Name)
            {                
                $returnValue = @{
                    Name        = $_.Name
                    Duration    = $_.Duration 
                    Exception   = $_.Exception
                    HasError    = $_.HasError
                    ReturnValue = $_.ReturnValue
                    Command     = $_.Command; 
                    Comment     = $_.Comment
                    Invoked     = $true
                } 
            } 
        }
        if ($null -eq $returnValue)
        {
            $returnValue = @{
                Name        = $action.Name
                Duration    = 0
                Exception   = $null
                HasError    = $false
                ReturnValue = $null
                Command     = $action.Command; 
                Comment     = $_.Comment
                Invoked     = $false
            }     
        }
    }
    else
    {
        Throw "Action $Name not found in Get-ActionState"
    }
    return $returnValue
}