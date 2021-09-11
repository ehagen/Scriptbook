Describe 'With Utilities Tests' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    It 'Start-ShellCmd' {
        $r = Start-ShellCmd -Command 'pwsh' -Arguments '-NonInteractive -NoLogo -OutputFormat Text -ExecutionPolicy Bypass -Command Get-Process'
        if ($r.ExitCode -ne 0) { throw "Invalid ExitCode returned from pwsh.exe : $($r.ExitCode)" }
        if ([string]::IsNullOrEmpty($r.StdOut)) { throw "No output found in shell command" }
        if (![string]::IsNullOrEmpty($r.StdErr)) { throw "Errors found in output shell command" }
    }

    It 'Set-EnvironmentVariable' {
        Set-EnvironmentVariable -n testVar -v testValue
        $r = [Environment]::GetEnvironmentVariable('testVar')
        Assert-Condition ($r -eq 'testValue') -Message 'Set-Env value'
    }

    It 'Assert-Operation' {
        $cnt = 5
        Assert-Condition -v $cnt -e 5 -m 'Error checking cnt condition'

        try
        {
            $cnt = 1
            Assert -v $cnt -o -eq -e 5 -m 'Error checking cnt condition'
        }
        catch
        {
            $cnt = 0
        }
        Assert-Condition ($cnt -ne 1) -Message 'Set-Env value'

        $name = 'hello'
        Assert-Condition -v $name -o -eq -e hello -m 'Error checking cnt condition'

        $d = 5.01
        Assert-Condition -v $d -o -eq -e 5.01 -m 'Error checking double condition'

    }

}
