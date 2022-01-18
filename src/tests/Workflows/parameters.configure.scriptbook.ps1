[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Import-Parameters ./parameters.to-import.ps1

Write-Host ''
Write-Host '=================================================='
Write-Host "Configure Scriptbook Parameters"
Write-Host '=================================================='

Read-ParameterValuesFromHost -Name 'Params'
Save-ParameterValues -Name 'Params' -Path './parameters.default-params.json'
