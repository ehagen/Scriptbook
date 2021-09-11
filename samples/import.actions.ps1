[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Action Hello {
    Write-Info "Hello"
}

Action GoodBy {
    Write-Info "GoodBy"
}