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
        $fileName = './my-parameter-values.json'

        # act
        Parameters -Name 'Params' -Path $fileName {
            @{
                ParamOne    = 'one'
                ParamTwo    = 'two'
            }
        }

        Save-ParameterValues -Name 'Params' -Path $fileName

        Parameters -Name 'Params' -Path $fileName {
            @{
                ParamOne    = '1'
                ParamTwo    = '2'
                ParamThree    = '3'
            }
        }

        Action Hello {
            Write-Info "Hello"
            $script:cnt++
        }

        Action GoodBy {
            Write-Info "GoodBy"
                    $script:cnt++
        }

        try
        {
            Start-Workflow -Name 'Workflow with saving & reading workflow parameters'
        }
        finally
        {
            Remove-Item -Path $filename -Force -ErrorAction Ignore

        }

        # assert
        $script:cnt | Should -Be 2

        $Params.ParamOne | Should -Be 'one'
        $Params.ParamTwo | Should -Be 'two'
        $Params.ParamThree | Should -Be '3'
    }

    It 'Should run scriptbook workflow with saving & reading workflow parameters secure' {
        # arrange
        $script:cnt = 0;

        # act
        Parameters -Name 'Params' {
            @{
                ParamOne    = 'one'
                ParamTwo    = 'two'
                ParamSecret = (ConvertTo-SecureString -String ('zcd7d0fcc926f073dff81de2c??') -AsPlainText -Force)
                ParamSecret2 = New-SecureStringStorage 'ppp7d0fcc926f073dff81de2c??'
            }
        }

        Action Hello {
            Write-Info "Hello"
            $Context.Params.ParamOne = '1.1'
            $Context.Params.ParamSecret = (ConvertTo-SecureString -String ('ycd7d0fcc926f073dff81de2c??') -AsPlainText -Force)
            Save-ParameterValues -Name 'Params' -Path './my-parameter-values.json'
            $Context.Params = @{}
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
            if (Test-IsSecureStringStorageObject $Context.Params.ParamSecret)
            {
                if (($Context.Params.ParamSecret.GetPlainString()) -eq 'ycd7d0fcc926f073dff81de2c??')
                {
                    $script:cnt++
                }
            }
            if (Test-IsSecureStringStorageObject $Context.Params.ParamSecret2)
            {
                if (($Context.Params.ParamSecret2.GetPlainString()) -eq 'ppp7d0fcc926f073dff81de2c??')
                {
                    $script:cnt++
                }
            }
        }

        try
        {
            Start-Workflow -Name 'Workflow with with saving & reading workflow parameters secure'
        }
        finally
        {
            $json = Get-Content -Path ./my-parameter-values.json -Raw
            Remove-Item -Path './my-parameter-values.json' -Force -ErrorAction Ignore

        }

        # assert
        $script:cnt | Should -Be 4

        $json.Contains('ycd7d0fcc926f073dff81de2c??') | Should -Be $false
        $json.Contains('ppp7d0fcc926f073dff81de2c??') | Should -Be $false
    }

    It 'Should configure scriptbook workflow parameters' {

        Mock Get-IsPowerShellStartedInNonInteractiveMode -ModuleName 'Scriptbook' {
            return $false
        }

        Mock Read-Host -ModuleName 'Scriptbook' { 
            if ($Prompt.Contains('ParamOne '))
            {
                return 'Hello'
            }
            else
            {
                return '' 
            }
        }
    
        # arrange
        $script:cnt = 0;
        Set-WorkflowInConfigureMode $true
        #$Global:WhatIfPreference = $true
        try
        {
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
        }
        finally
        {
            Set-WorkflowInConfigureMode $false
        }

        # assert
        $script:cnt | Should -Be 0
        $Context.Params.ParamOne | Should -Be 'Hello'
    }


    It 'Should edit scriptbook workflow parameters' {

        Mock Read-Host -ModuleName 'Scriptbook' { 
            if ($Prompt.Contains('ParamOne '))
            {
                return 'Hello'
            }
            else
            {
                return '' 
            }
        }
    
        # arrange
        $script:cnt = 0;
        try
        {
            # act
            Parameters -Name 'Params' {
                @{
                    ParamOne = 'one'
                    ParamTwo = 'two'
                }
            }

            Edit-WorkflowParameters -Name 'Params' -Path $null -Notice 'Edit the Workflow parameters in this test'
        }
        finally
        {
                
        }

        # assert
        $script:cnt | Should -Be 0
        $Context.Params.ParamOne | Should -Be 'Hello'
    }        

    It 'Should run scriptbook with -WhatIf' {

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

        # assert
        $Context.Params.ParamOne | Should -Be 'one'

        Start-Workflow -Name 'Workflow with Parameters' -WhatIf

        # assert
        $script:cnt | Should -Be 0
    }        
}