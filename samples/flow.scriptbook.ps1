Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

Flow -Name Flow1 -Actions Hello, Goodby -NoDepends {
    Action Hello {
        Write-Info "Hello from Flow 1"
    }

    Action GoodBy {
        Write-Info "GoodBy from Flow 1"
    }
}

Pipeline -Name Flow2 {
    Action Hello {
        Write-Info "Hello from Flow2"
    }

    Action GoodBy {
        Write-Info "GoodBy from Flow 2"
    }
}