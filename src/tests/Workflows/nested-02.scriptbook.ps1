[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Action Hello2 -Unique {
    Write-Info "Hello2"
}

Action GoodBy2 -Unique {
    Write-Info "GoodBy2"
}