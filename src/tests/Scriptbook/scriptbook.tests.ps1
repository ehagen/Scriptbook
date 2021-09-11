Describe 'with Functions Tests' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    Context 'AsJob and Parallel' {
        It 'CanRun Parallel' {

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
            
                Action Repeater -for { @('one', 'two', 'three', 'for') } -Parallel -Parameters @{CounterFile = $script:fn } {
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

    It 'CanRun AsJob' -Skip:($env:InScriptbookContainer -ne $null) {

        # arrange
        $script:fn = Join-Path (Get-TempPath) "$(New-Guid).txt"
        try
        {
            # act
            Action Start -Parameters @{CounterFile = $script:fn } {
                Write-Info "In action: $($args.Name)"
                Write-Info "With File: $($args.Parameters.CounterFile)"
                Set-Content -Path $args.Parameters.CounterFile -Value "1"
            }
        
            Action Background -AsJob -Tag HelloBackground -Parameters @{CounterFile = $script:fn } {
                Write-Info "In background Action: $($args.ActionName) $($args.Tag)"
                $v = Get-Content -Path $args.Parameters.CounterFile
                Set-Content -Path $args.Parameters.CounterFile -Value "$([int]$v + 1)"
            }
        
            Action Repeater -AsJob -For { @('one', 'two') } -Parameters @{CounterFile = $script:fn } {
                Write-Info "In Repeater: item: $($args.ForItem); Action: $($args.Name)"
                # add locking...
                if ($args.ForItem -eq 'two')
                {
                    Start-Sleep -Seconds 3
                }
                $v = Get-Content -Path $args.Parameters.CounterFile
                Set-Content -Path $args.Parameters.CounterFile -Value "$([int]$v + 1)"
            }
        
            Start-Workflow -Name CanRunAsJob

            # assert
            $v = Get-Content -Path $script:fn
            [int]$v | Should -Be 4
        }
        finally
        {
            Remove-Item $script:fn
        }
    } 


    Context 'Simple Hello' {
        It 'CanRun Simple' {
            # arrange
            $script:cnt = 0;

            # act
            Action Hello -Tag hello {
                Write-Info "Hello"
                $script:cnt++
            }

            Action GoodBy -ErrorAction Ignore {
                Write-Info "GoodBy"
                $script:cnt++
            }

            Action GoodByWrong -ErrorAction Ignore {
                Write-Info "GoodByWrong"
                Throw "MyException from GoodBy"
                $script:cnt++
            }

            Start-Workflow Hello, GoodBy, GoodByWrong -Name 'CanRun Simple'

            # assert
            $script:cnt | Should -Be 2
        }

    }

    Context 'Simple Workflows' {

        It 'SimpleFlow' {
            $script:cnt = 0
            $script:rv = 0
            Job 'One' -Tag 'StageOne' -If { $true } {
                Write-Info 'One'
                $script:cnt++
                # return
                $script:cnt;
            }

            Job 'Two' -Tag 'StageTwo' -If { $true } {
                Write-Info 'Two'
                $script:cnt++
                $script:rv = Get-ActionReturnValue -Name One
            }
            Start-flow -Name SimpleFlow

            # assert
            $script:cnt | Should -Be 2
            $script:rv | Should -Be 1
        }

        It 'SimpleFlow with If' {
            $script:cnt = 0;
            Action 'One' {
                Write-Info $args.Name
                $script:cnt++
            }
            Action 'Two' -If { $script:cnt -ne 1 } {
                Write-Info $args.Name
                $script:cnt++
            }
            Action 'Three' {
                Write-Info $args.Name
                $script:cnt++
            }
            Start-flow -Name SimpleFlowWithIf

            # assert
            $script:cnt | Should -Be 2
        }

        It 'SimpleFlow with Enable' {
            $script:cnt = 0;
            Action 'One' {
                Write-Info $args.Name
                Enable-Action Two
                $script:cnt++
            }
            Action 'Two' -Disabled {
                Write-Info $args.Name
                $script:cnt++
            }
            Action 'Three' {
                Write-Info $args.Name
                $script:cnt++
            }
            Start-flow -Name SimpleFlowWithEnable

            # assert
            $script:cnt | Should -Be 3
        }

        It 'SimpleFlow with Skip' {
            $script:cnt = 0;
            Action 'One' {
                Write-Info $args.Name
                $script:cnt++
            }
            Action 'Two' -Skip {
                Write-Info $args.Name
                $script:cnt++
            }
            Action 'Three' {
                Write-Info $args.Name
                $script:cnt++
            }
            Start-flow -Name SimpleFlowWithSkip

            # assert
            $script:cnt | Should -Be 2
        }

        It 'SimpleFlow with Flow Statement' {
            $script:cnt = 0;
            
            Flow 'One' -Tag StageOne {
                Write-Info $args.Name
                Write-Info $args.Tag
                $script:cnt++
            }
            Flow 'Two' -Tag StageTwo {
                Write-Info $args.Name
                Write-Info $args.Tag
                $script:cnt++
            }
            Start-Workflow -Name 'SimpleFlow with Flow Statement'

            # assert
            $script:cnt | Should -Be 2
        }

        It 'SimpleFlow with Next' {
            $script:cnt = 0;
            
            Action Hello -NextAction Goodby2 {
                Write-Info "Hello"
                $script:cnt++
            }
            
            Action GoodBy1 {
                Write-Info "GoodBy1"
                $script:cnt++
            }
            
            Action GoodBy2 {
                Write-Info "GoodBy2"
                $script:cnt | Should -Be 1
                $script:cnt++
            }
            
            Action GoodBy3 {
                Write-Info "GoodBy3"
                $script:cnt++
            }
            Start-Workflow -Name 'SimpleFlow with Next Statement'

            # assert
            $script:cnt | Should -Be 4
        }

        It 'SimpleFlow with Initialize and Complete Action' {
            $script:cnt = 0;
            
            Action 'One' -Tag StageOne {
                Write-Info $args.Name
                $script:cnt++
            }
            Action 'Two' -Tag StageTwo {
                Write-Info $args.Name
                $script:cnt++
            }

            Initialize-Action {
                $script:cnt++
            }   

            Complete-Action {
                $script:cnt++
            }

            Start-Workflow -Name ' Initialize and Complete Action'

            # assert
            $script:cnt | Should -Be 6
        }

        It 'SimpleDependsFlow' {
            $script:cnt = 0;

            Job 'Two' -Depends One {
                Write-Info $args.Name
                $script:cnt++
            }
            Job 'Three' -Depends One {
                Write-Info $args.Name
                $script:cnt++
            }
            Job 'Four' -Depends One {
                Write-Info $args.Name
                $script:cnt++
            }
            Job 'One' {
                Write-Info $args.Name
                $script:cnt++
            }
            Start-Workflow -Name 'SimpleDependsFlow'

            # assert
            $script:cnt | Should -Be 4
        }

        It 'SimpleFlow With Generation' {
            $script:cnt = 0;

            Job 'Build' -Tag 'Build' -If { return $true } {
                Write-Info $args.Name
                $script:cnt++
            }
            Job 'DeployDev2' -Tag 'DeployDev' -Depends DeployDev1 {
                Write-Info $args.Name
                $script:cnt++
            }
            Job 'DeployDev1' -Tag 'DeployDev' {
                Write-Info $args.Name
                $script:cnt++
            }
            Job 'DeployTst' -Tag 'DeployTst' -If { return $false } -Depends DeployDev2 {
                Write-Info $args.Name
                $script:cnt++
            }
            foreach ($acc in @('One', 'Two', 'Three'))
            {
                Job "DeployAcc-$acc" -Tag 'DeployAcc' -Parameters @{ Env = $acc } {
                    Write-Info 'Acc'
                    Write-Info $Args.Name
                    Write-Info $Args.Tag
                    Write-Info $args.Parameters.Env
                    $script:cnt++
                }
            }

            'One.2', 'Two.2', 'Three.2' | ForEach-Object {
                Job "DeployPrd-$_" -Tag 'DeployPrd' -Parameters @{ Env = $_ } {
                    Write-Info 'Prd'
                    Write-Info $Args.Name
                    Write-Info $Args.Tag
                    Write-Info $args.Parameters.Env
                    $script:cnt++
                }
            }

            Start-flow -Name 'SimpleFlow With Generation of Actions/Jobs'

            # assert
            $script:cnt | Should -Be 9
        }

        It 'SimpleFlow With Nested' {
            $script:cnt = 0;

            Action 'One' -Depends 'Two' {
                Action 'One.Three' -Depends 'One.One','One.Two' {
                    Write-Info 'One.Three'
                    $script:cnt++
                }
                Action 'One.One' {
                    $script:cnt | Should -Be 1
                    Write-Info 'One.One'
                    $script:cnt++
                }
                Action 'One.Two' {
                    $script:cnt | Should -Be 2
                    Write-Info 'One.Two'
                    $script:cnt++
                }
            }
            
            Action 'Two' {
                $script:cnt | Should -Be 0

                Action 'Two.One' {
                    Write-Info 'Two.One'
                    $script:cnt++
                }
            }

            Start-flow -Name 'SimpleFlow With Nested actions'

            # assert
            $script:cnt | Should -Be 4
        }

    }

}
