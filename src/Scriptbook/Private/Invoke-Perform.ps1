<#
.SYNOPSIS
    Performs a command/action
#>
function Invoke-Perform
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
        [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [string][alias('c')]$Command,
        $Code = $null,
        [alias('d')]$Depends = $null,
        [alias('Parameters')]$ActionParameters,
        [bool]$NoReEntry,
        [bool][alias('AsJob')]$aAsJob,
        $If,
        [switch]$NoDepends,
        $NextAction, 
        $For, 
        [switch]$Parallel,
        [switch]$Container,
        [HashTable]$ContainerOptions,
        $Session,
        [switch]$Isolated,
        [switch]$Manual,
        [string]$TypeName,
        [string[]]$RequiredVariables,
        $Comment,
        [switch]$SuppressOutput,
        [switch]$ConfirmAction,
        [switch]$WhatIfAction,
        [switch]$Multiple
    )

    $invokeErrorAction = $ErrorActionPreference

    # only way to set Error preference in Scriptblock
    $Global:ErrorActionPreference = $invokeErrorAction

    $dependencies = $Depends

    # simple depth first dependencies with attribute on functions
    if (-not $NoDepends.IsPresent)
    {
        if (!$Code)
        {
            if ($stepCommand = Get-Command -Name $Command -CommandType Function)
            {
                $d = $stepCommand.ScriptBlock.Attributes.Where{ $_.TypeId.Name -eq 'DependsOn' }
                if ($d) { $dependencies = $d.Name }
            }
        }

        # simple depth first dependencies
        foreach ($dependency in $dependencies)
        {
            if (!$dependency.StartsWith('Invoke-')) { $dependency = "Invoke-$dependency" }
            if ($dependency -NotIn $script:InvokedCommands)
            {
                if ($Command -notin $script:InvokedCommands)
                {
                    Invoke-PerformIfDefined -Command $dependency -ThrowError $true -Manual:$Manual.IsPresent
                    $Script:RootContext.IndentLevel += 1
                }
            }
        }
    }

    # Check re-entry
    if (!($NoReEntry))
    {
        if ($Command -in $script:InvokedCommands) { return; }
    }

    $cmdDisplayName = $Command.Replace('Action-', '').Replace('Invoke-', '')
    $skipped = $false

    # Re-apply PSake properties and Parameters in Scope
    try
    {
        if ((Test-Path variable:Script:PSakeProperties) -and $Script:PSakeProperties)
        {
            . $Script:PSakeProperties
        }
        if ((Test-Path variable:Script:PSakeInvocationParameters) -and $Script:PSakeInvocationParameters)
        {
            $Script:PSakeInvocationParameters.Keys | ForEach-Object { Set-Variable -Name $_ -Value $Script:PSakeInvocationParameters[$_] }
            $Script:PSakeInvocationParameters.Keys | ForEach-Object { Set-Variable -Name $_ -Value $Script:PSakeInvocationParameters[$_] -Scope Script }
        }
        if ((Test-Path variable:Script:PSakeInvocationProperties) -and $Script:PSakeInvocationProperties)
        {
            $Script:PSakeInvocationProperties.Keys | ForEach-Object { Set-Variable -Name $_ -Value $Script:PSakeInvocationProperties[$_] }
            $Script:PSakeInvocationProperties.Keys | ForEach-Object { Set-Variable -Name $_ -Value $Script:PSakeInvocationProperties[$_] -Scope Script }
        }
    }
    catch
    {
        Write-Warning "Issues in PSake properties and/or parameters"
        throw
    }

    # validate required variables
    if ($RequiredVariables -and $RequiredVariables.Count -gt 0)
    {
        $varsNotFound = [System.Collections.ArrayList]@()
        foreach ($var in $RequiredVariables)
        {
            If (!((Test-Path "variable:$var") -and ($null -ne (Get-Variable -Name $var))))
            {
                [void]$varsNotFound.Add($var)
            }
        }
        if ($varsNotFound.Count -gt 0)
        {
            Throw "Required variable(s) '$($varsNotFound -join ',')' not found in $cmdDisplayName"
        }
        $varsNotFound = $null
    }

    $indentSpaces = ''.PadRight(($Script:RootContext.IndentLevel + 2) , ' ')
    # check start condition
    if ($If)
    {
        $ifResult = & $If
        if (!$ifResult)
        {
            $skipped = $true
            Write-ScriptLog @{action = "$($indentSpaces)$($TypeName): $cmdDisplayName"; time = $(Get-Date -Format s); } -AsAction
            Write-Info 'Skipped:'
            $script:InvokedCommandsResult += @{ 
                Name        = "$cmdDisplayName"
                Duration    = 0
                Indent      = $Script:RootContext.IndentLevel
                Exception   = $null
                HasError    = $false
                ReturnValue = $null
                Command     = $Command
                TypeName    = $TypeName
                Comment     = $Comment
                Confirm     = $ConfirmAction
                WhatIf      = $WhatIfPreference
                Skipped     = $Skipped 
            }
            return;
        }
    }

    $commandStopwatch = [System.Diagnostics.Stopwatch]::StartNew();
    Write-ScriptLog @{action = "$($indentSpaces)$($TypeName): $(Get-AnsiColoredString -String $cmdDisplayName -Color 36 )"; time = $(Get-Date -Format s); } -AsAction

    Write-ScriptLog @{action = "$cmdDisplayName-Started"; time = $(Get-Date -Format s); } -AsAction -Verbose

    # check if we have something to execute
    if (!$Code)
    {
        if (!(Get-Item function:$Command -ErrorAction SilentlyContinue))
        {
            Throw "Required function '$Command' not found in script"
        }
    }
    
    $ex = $null
    $hasError = $false # determines if exception has occurred but not how exception is handled. When ErrorPreference is 'Continue' exception is null but hasError is true
    $codeReturn = $null
    Push-Location $Script:WorkflowLocation
    $prevInAction = $Script:RootContext.InAction
    $prevNestedActions = $Script:RootContext.NestedActions
    $prevWhatIfPreference = $WhatIfPreference
    $Script:RootContext.InAction = $true
    $Script:RootContext.NestedActions = New-Object -TypeName 'System.Collections.ArrayList'
    try
    {
        if ($WhatIfAction.IsPresent)
        {
            $WhatIfPreference = $true
        }

        if (!$WhatIfPreference)
        {
            if ($ConfirmAction.IsPresent)
            {
                $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes'
                $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No'
                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $choiceRTN = $host.UI.PromptForChoice('Confirm', "Are you sure you want to perform this action '$cmdDisplayName'", $options, 1)
                if ( $choiceRTN -eq 1 ) 
                {
                    $skipped = $true
                    Write-Info "Confirm: Skipping action '$cmdDisplayName'"                
                    return
                }
            }    
        }

        if (!$WhatIfPreference)
        {
            if ((Test-Path variable:Script:PSakeSetupTask) -and $Script:PSakeSetupTask)
            {
                & $Script:PSakeSetupTask $ActionParameters
            }
        }

        # check function without code
        if (!$Code -and (Get-IsPSFunctionDefinitionEmpty $Command)) { $skipped = $true; return; }

        if (!($Multiple.IsPresent))
        {
            $script:InvokedCommands += $Command
        }

        if (!$WhatIfPreference)
        {
            $beforePerform = Global:Invoke-BeforePerform -Command $Command
        }
        else
        {
            $beforePerform = $true
        }

        if ($beforePerform)
        {   
            # TODO: EH!! Refactor into multiple functions/code block
            # execute the code or function
            if ($Code)
            {
                $mp = $null
                if (!$Isolated.IsPresent)
                {
                    $module = Get-Module Scriptbook
                    if ($module)
                    {
                        $mp = $module.Path
                    }
                    else
                    {
                        throw "Module scriptbook loaded more than once. Only Import Scriptbook Module one time."
                    }
                }

                if ($For)
                {
                    $forResult = & $For
                    if ($Parallel.IsPresent -and $PSVersionTable.PSVersion.Major -ge 7)
                    {
                        $codeReturn = @()
                        $globalScriptVariables = Get-GlobalVarsForScriptblock -Isolated:$Isolated.IsPresent -AsHashTable
                        $codeAsString = $Code.ToString() # no scriptblock allowed in parallel ForEach :)
                        # $using:* is by ref with RunSpaces(parallel) but copy of var in Remoting
                        # $using:* needs to be thread-safe for parallel
                        if ($PSCmdlet.ShouldProcess($cmdDisplayName, "Invoke"))
                        {
                            $forResult | ForEach-Object -Parallel {
                                $vars = $using:globalScriptVariables
                                foreach ($v in $vars.GetEnumerator())
                                {
                                    Set-Variable $v.Key -Value $v.Value -WhatIf:$False -Confirm:$false
                                }
                                if ($using:mp)
                                {
                                    Import-Module $using:mp -Args @{ Quiet = $true }
                                }
                                $Parameters = $using:ActionParameters

                                $Parameters = $Parameters.Clone()
                                $Parameters.ForItem = $_
                                $Parameters.ForParallel = $true

                                # use local vars
                                Set-Variable ForItem -Value $_ -WhatIf:$False -Confirm:$false -Option Constant
                                Set-Variable ForParallel -Value $true -WhatIf:$False -Confirm:$false -Option Constant
                                Set-Variable Tag -Value $Parameters.Tag -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                                Set-Variable Name -Value $Parameters.Name -WhatIf:$False -Confirm:$false
                                Set-Variable ActionName -Value $Parameters.ActionName -WhatIf:$False -Confirm:$false -Option ReadOnly
                                foreach ($v in $Parameters.Parameters.GetEnumerator())
                                {
                                    Set-Variable $v.Key -Value $v.Value -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                                }

                                $code = [Scriptblock]::Create($using:codeAsString)
                                try 
                                {
                                    & $code $Parameters 
                                }
                                catch
                                {                                 
                                    $hasError = $true
                                    if ($using:invokeErrorAction -eq 'Continue')
                                    {
                                        Write-Host $_.Exception.Message -ForegroundColor White -BackgroundColor Red
                                        $ex = $_.Exception
                                    }
                                    elseif ($using:invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
                                    {
                                        Throw
                                    }
                                }
                            } | ForEach-Object { $codeReturn += $_ }
                            # TODO !!EH Pick-up if Exception --> hasError
                        }
                    }
                    elseif ($aAsJob)
                    {
                        $globalScriptVariables = Get-GlobalVarsForScriptblock -Isolated:$Isolated.IsPresent -AsHashTable
                        $codeAsString = $Code.ToString()
                        # $using:* is by ref with RunSpaces(parallel) but copy of var in Remoting
                        # $using:* needs to be thread-safe for parallel
                        if ($PSCmdlet.ShouldProcess($cmdDisplayName, "Invoke"))
                        {
                            $forResult | ForEach-Object { $item = $_; Start-Job -ScriptBlock {
                                    $vars = $using:globalScriptVariables
                                    foreach ($v in $vars.GetEnumerator())
                                    {
                                        Set-Variable $v.Key -Value $v.Value -WhatIf:$False -Confirm:$false
                                    }
                                    if ($using:mp)
                                    {
                                        Import-Module $using:mp -Args @{ Quiet = $true }
                                    }

                                    $Parameters = $using:ActionParameters

                                    $Parameters = $Parameters.Clone()
                                    $Parameters.ForItem = $using:item
                                    $Parameters.AsJob = $true

                                    # use local vars
                                    Set-Variable ForItem -Value $Parameters.ForItem -WhatIf:$False -Confirm:$false -Option Constant
                                    Set-Variable _ -Value $Parameters.ForItem -WhatIf:$False -Confirm:$false
                                    Set-Variable AsJob -Value $true -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                                    Set-Variable Tag -Value $Parameters.Tag -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                                    Set-Variable Name -Value $Parameters.Name -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                                    Set-Variable ActionName -Value $Parameters.ActionName -WhatIf:$False -Confirm:$false -Option ReadOnly
                                    foreach ($v in $Parameters.Parameters.GetEnumerator())
                                    {
                                        Set-Variable $v.Key -Value $v.Value -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                                    }

                                    $code = [Scriptblock]::Create($using:codeAsString)
                                    try
                                    {
                                        & $code $Parameters
                                    }
                                    catch
                                    {
                                        $hasError = $true
                                        if ($using:invokeErrorAction -eq 'Continue')
                                        {
                                            Write-Host $_.Exception.Message -ForegroundColor White -BackgroundColor Red
                                            $ex = $_.Exception
                                        }
                                        elseif ($using:invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
                                        {
                                            Throw
                                        }
                                    }
                                } 
                            } | Out-Null
                            Get-Job | Wait-Job | Out-Null
                            $codeReturn = Get-Job | Receive-Job
                            # TODO !!EH Pick-up if Exception --> hasError
                            Get-Job | Remove-Job | Out-Null
                        }
                    }
                    else
                    {
                        $r = @()
                        Set-Variable AsJob -Value $true -Scope Global -WhatIf:$False -Confirm:$false
                        Set-Variable Tag -Value $ActionParameters.Tag -Scope Global -WhatIf:$False -Confirm:$false
                        Set-Variable Name -Value $ActionParameters.Name -Scope Global -WhatIf:$False -Confirm:$false
                        Set-Variable ActionName -Value $ActionParameters.ActionName -Scope Global -WhatIf:$False -Confirm:$false
                        Set-Variable Parameters -Value $ActionParameters.Parameters -Scope Global -WhatIf:$False -Confirm:$false
                        foreach ($v in $ActionParameters.Parameters.GetEnumerator())
                        {
                            Set-Variable $v.Key -Value $v.Value -Scope Global -WhatIf:$False -Confirm:$false
                        }
                        foreach ($forItem in $forResult)
                        {
                            $ActionParameters.ForItem = $forItem
                            $ActionParameters.ForParallel = $false
                            Set-Variable ForItem -Value $forItem -Scope Global -WhatIf:$False -Confirm:$false
                            Set-Variable _ -Value $forItem -Scope Global -WhatIf:$False -Confirm:$false
                            if ($PSCmdlet.ShouldProcess("$cmdDisplayName with item '$($forItem)'", "Invoke"))
                            {
                                try 
                                {
                                    $r += & $Code $ActionParameters
                                }
                                catch
                                {
                                    $hasError = $true
                                    if ($invokeErrorAction -eq 'Continue')
                                    {
                                        Write-Host $_.Exception.Message -ForegroundColor White -BackgroundColor Red
                                        $ex = $_.Exception
                                    }
                                    elseif ($invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
                                    {
                                        Throw
                                    }
                                }
                            }
                        }
                        $codeReturn = $r
                        # TODO !!EH Pick-up if Exception --> hasError
                    }
                }
                elseif ($aAsJob)
                {
                    $globalScriptVariables = Get-GlobalVarsForScriptblock -Isolated:$Isolated.IsPresent -AsHashTable
                    $codeAsString = $Code.ToString()
                    $job = Start-Job -ScriptBlock {
                        $vars = $using:globalScriptVariables
                        foreach ($v in $vars.GetEnumerator())
                        {
                            Set-Variable $v.Key -Value $v.Value -WhatIf:$False -Confirm:$false
                        }
                        if ($using:mp)
                        {
                            Import-Module $using:mp -Args @{ Quiet = $true }
                        }
                        $parameters = $using:ActionParameters
                        Set-Variable Tag -Value $parameters.Tag -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                        Set-Variable Name -Value $parameters.Name -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                        Set-Variable ActionName -Value $parameters.ActionName -WhatIf:$False -Confirm:$false -Option ReadOnly
                        foreach ($v in $parameters.Parameters.GetEnumerator())
                        {
                            Set-Variable $v.Key -Value $v.Value -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                        }

                        $code = [Scriptblock]::Create($using:codeAsString)
                        try 
                        {
                            & $code $parameters
                        }
                        catch
                        {
                            $hasError = $true
                            if ($using:invokeErrorAction -eq 'Continue')
                            {
                                Write-Host $_.Exception.Message -ForegroundColor White -BackgroundColor Red
                                $ex = $_.Exception
                            }
                            elseif ($using:invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
                            {
                                Throw
                            }
                        }
                    }
                    if ($PSCmdlet.ShouldProcess($cmdDisplayName, "Invoke"))
                    {
                        $job | Wait-Job | Out-Null
                        $codeReturn = $job | Receive-Job
                        # TODO !!EH Pick-up if Exception --> hasError
                        $job | Remove-Job | Out-Null
                    }
                }
                elseif ($Container.IsPresent -or ($ContainerOptions.Count -gt 0))
                {
                    #TODO !!EH No nested action/code supported yet, detect nested code and wrap in workflow of it's own or add container support to Invoke-ActionSequence
                    if ($TypeName -eq 'Stage')
                    {
                        Write-Unsupported "Running Stage in Container"
                    }
                    else
                    {
                        Start-ScriptInContainer -ActionName $cmdDisplayName -ActionType $TypeName -Options $ContainerOptions -Parameters $ActionParameters -Isolated:$Isolated.IsPresent -Code $Code
                    }
                }
                elseif ($Session)
                {
                    if ($Isolated.IsPresent)
                    {
                        $sb = $Code
                    }
                    else
                    {
                        $globalScriptVariables = Get-GlobalVarsForScriptblock -Isolated:$Isolated.IsPresent -AsHashTable
                        $codeAsString = $Code.ToString()
                        $sb = {
                            $vars = $using:globalScriptVariables
                            foreach ($v in $vars.GetEnumerator())
                            {
                                Set-Variable $v.Key -Value $v.Value -WhatIf:$False -Confirm:$false
                            }

                            #TODO !!EH Do we need Scriptbook Module in remote, so yes install module remote (copy to remote first)
                            # if ($using:mp)
                            # {
                            #     Import-Module $using:mp -Args @{ Quiet = $true }
                            # }

                            $parameters = $using:ActionParameters
                            Set-Variable Tag -Value $parameters.Tag -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                            Set-Variable Name -Value $parameters.Name -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                            Set-Variable ActionName -Value $parameters.ActionName -WhatIf:$False -Confirm:$false -Option ReadOnly
                            foreach ($v in $parameters.Parameters.GetEnumerator())
                            {
                                Set-Variable $v.Key -Value $v.Value -WhatIf:$False -Confirm:$false -Option Constant -ErrorAction Ignore
                            }
                            $code = [Scriptblock]::Create($using:codeAsString)
                            try 
                            {
                                & $code $parameters
                            }
                            catch
                            {
                                $hasError = $true
                                if ($using:invokeErrorAction -eq 'Continue')
                                {
                                    Write-Host $_.Exception.Message -ForegroundColor White -BackgroundColor Red
                                    $ex = $_.Exception
                                }
                                elseif ($using:invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
                                {
                                    Throw
                                }
                            }
                        }

                    }
                    if ($PSCmdlet.ShouldProcess($cmdDisplayName, "Invoke"))
                    {
                        try
                        {
                            $codeReturn = Invoke-Command -Session $Session -ScriptBlock $sb -Args $ActionParameters
                        }
                        catch
                        {
                            $hasError = $true
                            if ($invokeErrorAction -eq 'Continue')
                            {
                                Write-ScriptLog $_.Exception.Message -AsError
                                $ex = $_.Exception
                            }
                            elseif ($invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
                            {
                                Throw
                            }
                        }
                    }
                }
                else
                {
                    Set-Variable AsJob -Value $true -Scope Global -WhatIf:$False -Confirm:$false
                    Set-Variable Tag -Value $ActionParameters.Tag -Scope Global -WhatIf:$False -Confirm:$false
                    Set-Variable Name -Value $ActionParameters.Name -Scope Global -WhatIf:$False -Confirm:$false
                    Set-Variable ActionName -Value $ActionParameters.ActionName -Scope Global -WhatIf:$False -Confirm:$false
                    Set-Variable Parameters -Value $ActionParameters.Parameters -Scope Global -WhatIf:$False -Confirm:$false
                    if ($PSCmdlet.ShouldProcess($cmdDisplayName, "Invoke"))
                    {
                        try
                        {
                            $codeReturn = & $Code $ActionParameters
                        }
                        catch
                        {
                            $hasError = $true
                            if ($invokeErrorAction -eq 'Continue')
                            {
                                Write-ScriptLog $_.Exception.Message -AsError
                                $ex = $_.Exception
                            }
                            elseif ($invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
                            {
                                Throw
                            }
                        }
                    }
                }
            }
            else
            {
                if ($PSCmdlet.ShouldProcess($cmdDisplayName, "Invoke"))
                {
                    try 
                    {
                        $codeReturn = &"$Command"
                    }
                    catch
                    {
                        $hasError = $true
                        if ($invokeErrorAction -eq 'Continue')
                        {
                            Write-ScriptLog $_.Exception.Message -AsError
                            $ex = $_.Exception
                        }
                        elseif ($invokeErrorAction -notin 'Ignore', 'SilentlyContinue')
                        {
                            Throw
                        }
                    }
                }
            }

            # execute nested actions
            if ($Script:RootContext.NestedActions.Count -gt 0)
            {
                $Script:RootContext.IndentLevel += 1
                try
                {
                    Invoke-ActionSequence -Actions $Script:RootContext.NestedActions -ThrowError $true -Test:$Test.IsPresent -WhatIf:$WhatIfPreference
                }
                finally
                {
                    $Script:RootContext.IndentLevel -= 1
                }
            }

            # show ReturnValue(s) on console
            if ($codeReturn -and !$SuppressOutput.IsPresent)
            {
                if ($codeReturn -is [array])
                {
                    foreach ($line in $codeReturn)
                    {
                        if ($line -is [string])
                        {
                            Write-Info $line
                        }
                        else
                        {
                            $line
                        }
                    }
                }
                else
                {
                    $codeReturn
                }
            }

            if (!$WhatIfPreference)
            {
                Global:Invoke-AfterPerform -Command $Command

                if ((Test-Path variable:Script:PSakeTearDownTask) -and $Script:PSakeTearDownTask)
                {
                    & $Script:PSakeTearDownTask $ActionParameters
                }
            }
        }
        
    }
    catch
    {
        $hasError = $true
        if ($invokeErrorAction -eq 'Stop')
        {
            $ex = $_.Exception
            Global:Invoke-AfterPerform -Command $Command -ErrorRecord $_
            Global:Write-OnLogException -Exception $ex
            Throw
        }
        if ($invokeErrorAction -eq 'Continue')
        {
            $ex = $_.Exception
            Write-ExceptionMessage $_ -TraceLineCnt 5 -ScriptBlocksOnly
            Global:Invoke-AfterPerform -Command $Command -ErrorRecord $_
            Global:Write-OnLogException -Exception $ex
        }
        elseif ($invokeErrorAction -eq 'ContinueSilently')
        {
            Global:Invoke-AfterPerform -Command $Command
        }
        else
        {
            # ignore
            Global:Invoke-AfterPerform -Command $Command
        }
    }
    finally
    {
        Write-ScriptLog @{action = "$cmdDisplayName-Finished"; time = $(Get-Date -Format s); } -AsError:($null -ne $ex) -AsAction -Verbose
        $Script:RootContext.InAction = $prevInAction
        $Script:RootContext.NestedActions = $prevNestedActions
        $indent = $Script:RootContext.IndentLevel
        if ($Manual.IsPresent)
        {
            $indent += 1
        }
        $script:InvokedCommandsResult += @{ 
            Name        = "$cmdDisplayName"
            Duration    = $commandStopwatch.Elapsed
            Indent      = $indent
            Exception   = $ex
            HasError    = $hasError
            ReturnValue = $codeReturn
            Command     = $Command
            TypeName    = $TypeName
            Comment     = $Comment
            Confirm     = $ConfirmAction
            WhatIf      = $WhatIfPreference
            Skipped     = $Skipped
        }
    
        if ($WhatIfAction.IsPresent)
        {
            $WhatIfPreference = $prevWhatIfPreference
        }

        Pop-Location
    }

    if ($NextAction)
    {
        if ($PSCmdlet.ShouldProcess($NextAction, "Invoke"))
        {
            $action = "Action-$NextAction"
            Invoke-PerformIfDefined -Command $action -ThrowError $ThrowError -Test:$Test.IsPresent -WhatIf:($WhatIfPreference -or $WhatIfAction.IsPresent)
        }
    }
}
