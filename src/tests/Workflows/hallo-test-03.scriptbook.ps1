Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello {
    Write-Info "Hello"
    $script:Counter++
}

Action GoodBy {
    Write-Info "GoodBy"
    $script:Counter++
}

Tests 'Basic tests' {
    Test -Name TestHello {
        # arrange

        # act
        $r = Invoke-Action -Name Hello

        # assert
        Assert ($r -ne $null) "Action error in Action: Hello"
        Assert ($script:Counter -eq 2) "Action error in Action: Hello"
    }

    Test -Name TestGoodby {
        # arrange

        # act
        $r = Invoke-Action -Name Goodby

        # assert
        Assert ($r -ne $null) "Action error in Action: Goodby"
        Assert ($script:Counter -eq 3) "Action error in Action: Goodby"
    }
}

Setup 'Setup Environment' {
    if (Get-WorkflowSetting InTest)
    {
        $script:Counter++
    }
}

Teardown 'Teardown Environment' {
    if (Get-WorkflowSetting InTest)
    {
        $script:Counter++
        Assert ($script:Counter -eq 4) "Teardown test error"
    }
    else
    {
        Assert ($script:Counter -eq 2) "Teardown workflow error"
    }
}

$script:Counter = 0
Start-Workflow -Name Hello -Test 

$script:Counter = 0
Start-Workflow -Name Hello
