Describe 'Scriptbook workflows with Variables' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    It 'Should Run Action AsJob' -Skip:($env:InScriptbookContainer -ne $null) {

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


}