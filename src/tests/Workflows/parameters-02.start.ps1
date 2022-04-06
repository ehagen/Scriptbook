[CmdletBinding()]
param(
    $Actions,
    [switch]$Configure
)

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Start-Scriptbook -File ./parameters-02.scriptbook.ps1 -Actions $Actions -Parameters $parameters -Configure:$Configure
