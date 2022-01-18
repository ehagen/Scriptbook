Describe 'Scriptbook workflows with Parameters' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    It 'Should run scriptbook workflow with workflow parameters' {
        # arrange
        $script:cnt = 0;

        # act
        Parameters -Name 'Params' {
            @{
                ParamOne = 'one'
                ParamTwo = 'two'
            }
        }

        Variables -Name 'Samples' {
            @{
                ParamThree = 'three'
            }
        }

        Action Hello {
            Write-Info "Hello"
            $ctx = Get-WorkflowContext
            if ($ctx.Params.ParamOne -eq 'one')
            {
                $script:cnt++
                $ctx.Params.ParamOne = '1'
            }
        }

        Action GoodBy {
            Write-Info "GoodBy"
            $ctx = Get-WorkflowContext
            if ($ctx.Params.ParamOne -eq '1')
            {
                $script:cnt++
            }
            if ($ctx.Params.ParamTwo -eq 'two')
            {
                $script:cnt++
            }
            if ($ctx.Samples.ParamThree -eq 'three')
            {
                $script:cnt++
            }
        }

        Start-Workflow -Name 'Workflow with Parameters'

        # assert
        $script:cnt | Should -Be 4
    }

    It 'Should run scriptbook workflow with multiple workflow parameters' {
        # arrange
        $script:cnt = 0;

        # act
        Parameters -Name 'Params' {
            @{
                ParamOne = 'one'
                ParamTwo = 'two'
            }
        }
        Parameters -Name 'Params' -Override {
            @{
                ParamOne = 'three'
                ParamTwo = 'four'
            }
        }

        Variables -Name 'Samples' {
            @{
                ParamThree = 'three'
            }
        }

        Action Hello {
            Write-Info "Hello"
            if ($Context.Params.ParamOne -eq 'three')
            {
                $script:cnt++
                $Context.Params.ParamOne = '1'
            }
        }

        Action GoodBy {
            Write-Info "GoodBy"
            if ($Context.Params.ParamOne -eq '1')
            {
                $script:cnt++
            }
            if ($Context.Params.ParamTwo -eq 'four')
            {
                $script:cnt++
            }
            if ($Context.Samples.ParamThree -eq 'three')
            {
                $script:cnt++
            }
        }

        Start-Workflow -Name 'Workflow with multiple Parameters'

        # assert
        $script:cnt | Should -Be 4
    }

    It 'Should run scriptbook workflow with complex workflow parameters' {
        # arrange
        $script:cnt = 0;

        # act
        Parameters -Name 'Params' {
            @{
                ParamOne = @{
                    Default     = 'one'
                    Description = 'ParamOne'
                    Type        = 'string'
                }
                ParamTwo = 'two'
            }
        }

        Action Hello {
            Write-Info "Hello"
            if ($Context.Params.ParamOne.Default -eq 'one')
            {
                $script:cnt++
                $Context.Params.ParamOne = '1' # overwrite current values
            }
        }

        Action GoodBy {
            Write-Info "GoodBy"
            if ($Context.Params.ParamOne -eq '1')
            {
                $script:cnt++
            }
            if ($Context.Params.ParamTwo -eq 'two')
            {
                $script:cnt++
            }
        }

        Start-Workflow -Name 'Workflow with Complex Parameters'

        # assert
        $script:cnt | Should -Be 3
    }

    It 'Should run scriptbook workflow with saving & reading workflow parameters' {
        # arrange
        $script:cnt = 0;

        # act
        Parameters -Name 'Params' {
            @{
                ParamOne = 'one'
                ParamTwo = 'two'
            }
        }

        Action Hello {
            Write-Info "Hello"
            $Context.Params.ParamOne = '1.1'
            Save-ParameterValues -Name 'Params' -Path './my-parameter-values.json'
            $script:cnt++
        }

        Action GoodBy {
            Write-Info "GoodBy"
            $Context.Params.ParamOne = 'one'
            Read-ParameterValues -Name 'Params' -Path './my-parameter-values.json'
            if ($Context.Params.ParamOne -eq '1.1')
            {
                $script:cnt++
            }
        }

        try
        {
            Start-Workflow -Name 'Workflow with Complex Parameters'
        }
        finally
        {
            Remove-Item -Path './my-parameter-values.json' -Force -ErrorAction Ignore
        }

        # assert
        $script:cnt | Should -Be 2
    }

}