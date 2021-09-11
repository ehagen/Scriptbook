Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Use-Workflow -Name Flow1 {
    Action Hello {
        Write-Info "Hello from Flow 1"
    }

    Action GoodBy {
        Write-Info "GoodBy from Flow 1"
    }
}

Flow -Name Flow2 -Actions Hello, Goodby -NoDepends {
    Action Hello {
        Write-Info "Hello from Flow 2"
    }

    Action GoodBy {
        Write-Info "GoodBy from Flow 2"
    }
}

Pipeline -Name Flow3 {
    Action Hello {
        Write-Info "Hello from Flow3"
    }

    Action GoodBy {
        Write-Info "GoodBy from Flow 3"
    }
}