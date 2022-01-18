Describe 'Scriptbook workflows with Parallel Actions' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    It 'Should Run with Loops in Parallel' {

        # arrange
        $script:fn = Join-Path (Get-TempPath) "$(New-Guid).txt"
        try
        {
            # act
            Action Start -Parameters @{CounterFile = $script:fn } {
                Write-Info "In action: $($Args.Name)"
                Write-Info "With File: $($args.Parameters.CounterFile)"
                Set-Content -Path $args.Parameters.CounterFile -Value "1"
            }
        
            Action Repeater -For { @('one', 'two', 'three', 'for') } -Parallel -Parameters @{CounterFile = $script:fn } {
                Write-Info "In Repeater: item: $($args.ForItem); Action: $($args.Name)"
                $mutex = New-Object System.Threading.Mutex($false, 'Global\TesterStepper')
                try
                {
                    try
                    {
                        $Mutex.WaitOne(1000 * 10)
                    }
                    catch [System.Threading.AbandonedMutexException]
                    {
                        # we now own the mutex, continue as usual
                    }                    
                    $v = Get-Content -Path $args.Parameters.CounterFile
                    Set-Content -Path $args.Parameters.CounterFile -Value "$([int]$v + 1)"
                }
                finally
                {
                    $mutex.Close()
                }                
            }
        
            Start-Workflow -Name CanRunParallel

            # assert
            $v = Get-Content -Path $script:fn
            [int]$v | Should -Be 5
        }
        finally
        {
            Remove-Item $script:fn
        }
    }  
}