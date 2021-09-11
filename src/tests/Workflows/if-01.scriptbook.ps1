Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello {
    Write-Info $args.Name
    $script:SayGoodby = $false
}

Action GoodBy -If { $script:SayGoodby } {
    Write-Info $args.Name
}

Action Hello2 {
    Write-Info $args.Name
    $script:SayGoodby = $true
}

Action GoodBy2 -If { $script:SayGoodby } {
    Write-Info $args.Name
}

Start-Workflow -Name If