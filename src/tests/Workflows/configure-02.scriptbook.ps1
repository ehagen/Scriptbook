Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force -Args @{ 
    Quiet   = $true
    Core    = $true
    Reset   = $false
    Depends = @(
        @{
            Module         = 'TD.Util'
            MinimumVersion = '1.00';
            Force          = $false
            Args           = @{ Quiet = $true } 
        }) 
}

Action Hello {
    Write-Info "Hello"
}

Action GoodBy {
    Write-Info "GoodBy"
}

Start-Workflow -Name Configure