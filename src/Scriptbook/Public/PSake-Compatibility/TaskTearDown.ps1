#Set-Alias -Name ActionTearDown -Value TaskTearDown -Scope Global -Force -WhatIf:$false
Set-Alias -Name Complete-Action -Value TaskTearDown -Scope Global -Force -WhatIf:$false
function TaskTearDown
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$TearDown
    )
    $Script:PsakeTearDownTask = $TearDown
}