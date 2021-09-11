Describe 'with Functions Tests' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }


    It 'CanRun With Info' {

        # arrange
        $script:cnt = 0;

        Info {
            <#
                # Sample Info

                This is information about the info and more can be in this actions for this Scriptbook

                ## Sub section

                This is information about this subsection and more

                # Show-Markdown

                ## Markdown

                You can now interact with Markdown via PowerShell!

                *stars*
                __underlines__
                    
                ``` Powershell
                Write-Info "Sample powershell code"
                Write-Info "With more lines"
                foreach ($t in $Tokens)
                {
                    Write-Info $t
                }
                ```
            #>
        }

        # act
        Action Hello -Tag hello {
            Write-Info "Hello"
            $script:cnt++
        }

        Action GoodBy -ErrorAction Ignore {
            Write-Info "GoodBy"
            $script:cnt++
        }

        Info {
            <#
            # Good Warning INFO

            - more
            - two
            - three

            #>
        }

        Action GoodByWrong -ErrorAction Ignore {
            Info {
                <#
                # GoodBy Wrong

                More info will follow on this subject I Believe
                #>
            }
            Write-Info "GoodByWrong"
            Throw "MyException from GoodBy"
            $script:cnt++
        }

        Start-Workflow Hello, GoodBy, GoodByWrong -Name 'CanRun with Info'

        # assert
        $script:cnt | Should -Be 2
    }

    It 'CanRun With Sections' -Skip {
        # arrange
        $script:cnt = 0;

        # Block / Cell
        Section InComments {
            <#
            # Title
            
            This is a paragraph start in markdown

            ## Heading 2

            And one more Item
            #>
        }

        Section InPowershell {
            @"
# Sample Output

This is a paragraph

## Heading 2

And one more item
"@
        }

        Section 'InPowershell 2' {
            '# Sample Output'
            ''
            'This is a paragraph'
            ''
            '## Heading 2'
            ''
            'And one more item'
        }

        Section 'Minimal Markdown' {
            L '# Sample Output'
            L
            L 'This is a paragraph'
            L 
            L '## Heading 2'
            L 
            L 'And one more item'
        }

        S 'Minimal Markdown 2' {
            L '# Sample Output'
            L
            L 'This is a paragraph'
            L 
            L '## Heading 2'
            L 
            L 'And one more item'
        }

        Markdown 'Minimal Markdown 3' {
            m '# Sample Output'
            m
            m 'This is a paragraph'
            m 
            m '## Heading 2'
            m 
            m 'And one more item'
        }
        
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

        Start-Workflow Hello, GoodBy, GoodByWrong -Name 'CanRun with Sections'

        # assert
        $script:cnt | Should -Be 2
    }

}
