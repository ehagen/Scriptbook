Describe 'Psake Workflow compatibility' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    Context 'Run PSake Tasks' {

        It 'Should Run Simple PSake workflow' {
            
            # arrange
            $script:cnt = 0;

            Properties {
                $MyVar = "MyVarValue"
            }
            
            # act
            Task Hello -Tag hello {
                Write-Info "Hello"
                $script:cnt++
            }

            Task GoodBy -ContinueOnError {
                Write-Info "GoodBy"
                Write-Info $MyVar
                $script:cnt++
            }

            Task GoodByWrong -ContinueOnError {
                Write-Info "GoodByWrong"
                Throw "MyException from GoodBy"
                $script:cnt++
            }

            Task Default -depends Hello, GoodBy, GoodByWrong

            # assert
            $script:cnt | Should -Be 2
        }

        It 'Should Run PSake task(s) with import Tasks -FromModule PowershellBuild' -Skip {
            # arrange
            $script:cnt = 0;

            Push-Location ../
                        
            #Import-Module PowerShellBuild
            Task Build -FromModule PowerShellBuild
    
            Task Default -depends Build
    
            # assert
            $script:cnt | Should -Be 0
        }
    
    }
}