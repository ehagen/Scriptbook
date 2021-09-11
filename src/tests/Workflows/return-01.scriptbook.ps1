Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello {
    $args.Name
}

Action GoodBy {
    $args.Name
}

Start-Workflow  -Name Return