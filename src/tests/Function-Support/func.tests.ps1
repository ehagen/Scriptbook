Describe 'with Functions Tests' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    It 'Use Depends On Attribute' -Skip {

        # arrange
        $script:cnt = 0;

        # act
        function Invoke-Hello
        {
            Write-Info "Hello"
            $script:cnt++
        }

        function Invoke-GoodBy
        {
            [DependsOn(("Hello"))]param()
            Write-Info "GoodBy"
            $script:cnt++
        }

        function Invoke-GoodBy2
        {
            [DependsOn(("Hello"))]param()
            Write-Info "GoodBy"
            $script:cnt++
        }

        function Invoke-GoodBy3
        {
            [DependsOn(("Hello", 'GoodBy2'))]param()
            Write-Info "GoodBy"
            $script:cnt++
        }

        Start-Workflow GoodBy, GoodBy3

        # assert
        $script:cnt | Should -Be 4

    }
}
