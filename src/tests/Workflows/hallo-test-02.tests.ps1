Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

. ./hallo-test-02.actions.ps1

$script:Counter = 0

Test -Name TestHello {
    # arrange

    # act
    $r = Invoke-Action -Name Hello

    # assert
    Assert ($r -ne $null) "Action error in Action: Hello"
    Assert ($script:Counter -eq 1) "Error in Action: Hello"
}

Test -Name TestGoodby {
    # arrange

    # act
    $r = Invoke-Action -Name Goodby

    # assert
    Assert ($r -ne $null) "Action error in Action: Goodby"
    Assert ($script:Counter -eq 2) "Error in Action: Goodby"
}

Start-Workflow  -Name Hello -Test #-Whatif
