[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Action Hello4 {
    Write-Info "Hello4"
}

Action GoodBy4 {
    Write-Info "GoodBy4"
}