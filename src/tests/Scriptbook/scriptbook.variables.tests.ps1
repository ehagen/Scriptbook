Describe 'Scriptbook workflows with Variables' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    It 'Should run Scriptbook Workflow with Workflow Variables' {
        # arrange
        $script:cnt = 0;

        # act
        Variables -Name Samples {
            @{
                OneVar = 'one'
                TwoVar = 'two'
            }
        }
        Variables -Name Samples2 {
            @{
                OneVar = 'one'
                TwoVar = 'two'
            }
        }
        Variables -Name Samples2 -Override {
            @{
                OneVar = 'one'
                TwoVar = 'three'
            }
        }
        Action Hello {
            Write-Info "Hello"
            $ctx = Get-WorkflowContext
            if ($ctx.Samples.OneVar -eq 'one')
            {
                $script:cnt++
                $ctx.Samples.OneVar = '1'
            }
        }

        Action GoodBy {
            Write-Info "GoodBy"
            $ctx = Get-WorkflowContext
            if ($ctx.Samples.OneVar -eq '1')
            {
                $script:cnt++
            }
            if ($ctx.Samples.TwoVar -eq 'two')
            {
                $script:cnt++
            }
            if ($ctx.Samples2.TwoVar -eq 'three')
            {
                $script:cnt++
            }
        }

        Start-Workflow -Name 'Workflow with Variables'

        # assert
        $script:cnt | Should -Be 4
    }

}