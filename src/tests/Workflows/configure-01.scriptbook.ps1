Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello {
    Write-Info "Hello"
    Write-Info $HelloFromConfigure
}

Action GoodBy {
    Write-Info "GoodBy"
    Write-Info $GoodbyFromConfigure
}

Start-Workflow -Name Configure