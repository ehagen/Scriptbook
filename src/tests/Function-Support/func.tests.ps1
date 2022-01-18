Describe 'Functions support Workflows' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    <#
    Remark: For testing this in Pester we need to make our functions global with Global: prefix.
            For use in scriptbook this is not necessary.
    #>
    It 'Should Use [DependsOn] Attribute' {

        # arrange
        $script:cnt = 0;

        # act
        function Global:Invoke-Hello
        {
            Write-Info "Hello"
            $script:cnt++
        }

        function Global:Invoke-GoodBy
        {
            [DependsOn("Hello")]param()
            Write-Info "GoodBy"
            $script:cnt++
        }

        function Global:Invoke-GoodBy2
        {
            [DependsOn("Hello")]param()
            Write-Info "GoodBy"
            $script:cnt++
        }

        function Global:Invoke-GoodBy3
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
