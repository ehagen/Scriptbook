Set-Location $PSScriptRoot

# load import settings from configure-01.scriptbook.psd1
Import-Module ../../Scriptbook/Scriptbook.psm1 -Force -Args @{ 
    SettingsFile  = './configure-01.scriptbook.psd1'
}
 
Action Hello {
    Write-Info "Hello"
    Write-Info $HelloFromConfigure
}

Action GoodBy {
    Write-Info "GoodBy"
    Write-Info $GoodbyFromConfigure
}

Start-Workflow -Name Configure