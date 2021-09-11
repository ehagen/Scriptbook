Set-Alias -Name Invoke-PSake -Value Start-PSakeWorkflow -Scope Global -Force -WhatIf:$false
function Start-PSakeWorkflow
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string] $File,
        [Parameter(Position = 1)][HashTable] $Parameters,
        [Parameter(Position = 2)][HashTable] $Properties
    )

    if ($PSCmdlet.ShouldProcess("Start-PSakeWorkflow"))
    {
        $Script:PsakeInvocationParameters = $Parameters
        $Script:PsakeInvocationProperties = $Properties

        . $File
    }
}
