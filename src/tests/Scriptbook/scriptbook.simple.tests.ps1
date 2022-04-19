Describe 'Simple Workflows' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    It 'Should Run Simple workflow' {
        # arrange
        $script:cnt = 0;

        # act
        Action Hello -Tag hello {
            Write-Info "Hello"
            $script:cnt++
        }

        Action GoodBy -ErrorAction Ignore {
            "GoodBy" | Out-ScriptbookHost
            $script:cnt++
        }

        Action GoodByWrong -ErrorAction Ignore {
            "GoodByWrong" | Out-Info
            Throw "MyException from GoodBy"
            $script:cnt++
        }

        Start-Workflow Hello, GoodBy, GoodByWrong -Name 'CanRun Simple'

        # assert
        $script:cnt | Should -Be 2
    }

    It 'Should Run Simple workflow with WhatIf action' {
        # arrange
        $script:cnt = 0;

        # act
        Action Hello {
            Write-Info "Hello"
            $script:cnt++
        }

        Action GoodBy -Confirm {
            "GoodBy" | Out-ScriptbookHost
            $script:cnt++
        }

        Start-Workflow * -Name 'CanRun Simple WhatIf' -WhatIf

        # assert
        $script:cnt | Should -Be 0
    }        

    It 'Should run simple workflow with Job action' {
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
        Start-Flow -Name SimpleFlow

        # assert
        $script:cnt | Should -Be 2
        $script:rv | Should -Be 1
    }

    It 'Should run simple workflow with Always action' {
        $script:cnt = 0;
        Action 'One' {
            Write-Info $args.Name
            Throw "Positive test Error in One.Always"
            $script:cnt++
        }
        Action 'Two' {
            Write-Info $args.Name
            $script:cnt++
        }
        Action 'Three' -Always {
            Write-Info $args.Name
            $script:cnt++
        }

        Start-Workflow -Name SimpleFlowWithAlways -ErrorAction Continue

        # assert
        $script:cnt | Should -Be 1
    }

    It 'Should run simple workflow with check Action State' {
        $script:cnt = 0;
        Action 'One' -ErrorAction Continue {
            Write-Info $args.Name
            Throw "Error in One.CheckState"
            $script:cnt++
        }
        Action 'Two' -If { (Get-ActionState -Name One).HasError } {
            Write-Info $args.Name
            $script:cnt++
            $script:cnt++
        }
        Action 'Three' -If { !(Get-ActionState -Name Two).HasError } {
            Write-Info $args.Name
            $script:cnt++
            $script:cnt++
            $script:cnt++
        }

        Start-Workflow -Name SimpleFlowWithCheckActionState -ErrorAction Continue

        # assert
        $script:cnt | Should -Be 5
    }

    It 'Should run simple workflow with If action' {
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
        Start-Flow -Name SimpleFlowWithIf

        # assert
        $script:cnt | Should -Be 2
    }

    It 'Should run simple workflow with Enable action' {
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
        Start-Flow -Name SimpleFlowWithEnable

        # assert
        $script:cnt | Should -Be 3
    }

    It 'Should run simple workflow with Skip action' {
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
        Start-Flow -Name SimpleFlowWithSkip

        # assert
        $script:cnt | Should -Be 2
    }

    It 'Should run simple workflow with Flow Statement' {
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

    It 'Should run simple workflow with Next Action' {
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

    It 'Should run simple workflow with Initialize and Complete Action' {
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

    It 'Should run simple workflow with Dependency Flow' {
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

    It 'Should run simple workflow with Action Generation on the fly' {
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

        Start-Flow -Name 'SimpleFlow With Generation of Actions/Jobs'

        # assert
        $script:cnt | Should -Be 9
    }

    It 'Should run simple workflow with Nested actions' {
        $script:cnt = 0;

        Action 'One' -Depends 'Two' {
            Action 'One.Three' -Depends 'One.One', 'One.Two' {
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

            Add-WorkflowNotification 'Use url: https://sample.com'
            Add-WorkflowNotification ''.PadRight(78, '-')

        }

        Start-Flow -Name 'SimpleFlow With Nested actions'

        # assert
        $script:cnt | Should -Be 4
    }

    It 'Should run simple workflow with workflow start Action selection' {
        # arrange
        $script:cnt = 0;

        # act
        Action Hello {
            Write-Info "Hello"
            $script:cnt++
        }

        Action Hello2 {
            Write-Info "Hello2"
            $script:cnt++
        }

        Action Hello3 {
            Write-Info "Hello3"
            $script:cnt++
        }

        Action GoodBy {
            Write-Info "GoodBy"
            $script:cnt++
        }


        Start-Workflow Hello* -Name 'Workflow with Action selection'

        # assert
        $script:cnt | Should -Be 3
    }

    It 'Should run simple workflow with allow Action execution multiple times and show verbose output' {
        # arrange
        $script:cnt = 0;

        # act
        Action Hello -Multiple {
            Write-Info "Hello"
            'Hello from Verbose' | Out-NullSb
            $script:cnt++
        }

        Action Hello2 {
            Write-Info "Hello2"
            'Hello2 from Verbose' | Out-NullSb
            $script:cnt++
        }

        Action Hello3 {
            Write-Info "Hello3"
            'Hello3 from Verbose' | Out-ScriptbookVerbose
            Invoke-Action Hello
            Invoke-Action Hello
            $script:cnt++
        }

        Action GoodBy {
            Write-Info "GoodBy"
            'Goodby from Verbose' | Out-Verbose
            $script:cnt++
        }

        Start-Workflow -Name 'Workflow with Multiple times call action' -Verbose

        # assert
        $script:cnt | Should -Be 6
    }
}
