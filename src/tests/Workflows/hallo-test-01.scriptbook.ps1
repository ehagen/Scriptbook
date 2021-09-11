Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

$script:Counter = 0

Action Hello {
    Write-Info "Hello"
    $script:Counter++
}

Action GoodBy {
    Write-Info "GoodBy"
    $script:Counter++
}

Test -Name TestHello {
    # arrange

    # act
    $r = Invoke-Action -Name Hello

    # assert
    Assert ($r -ne $null) "Action error in Action: Hello"
    Assert ($script:Counter -eq 1) "Action error in Action: Hello"
}

Test -Name TestGoodby {
    # arrange

    # act
    $r = Invoke-Action -Name Goodby

    # assert
    Assert ($r -ne $null) "Action error in Action: Goodby"
    Assert ($script:Counter -eq 2) "Action error in Action: Goodby"
}

Start-Workflow -Name Hello -Test 
