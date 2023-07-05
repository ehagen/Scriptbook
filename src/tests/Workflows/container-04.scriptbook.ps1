Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action HelloWorld -Container {
    Write-Host "Inside HelloWorld"
}

Action GoodBy -Container {
    Write-Host "Inside GoodBy"

}

Start-Workflow