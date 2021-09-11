[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Action Hello3 {
    Write-Info "Hello3"
}

Action GoodBy3 {
    Write-Info "GoodBy3"
    . ./nested-04.scriptbook.ps1
}