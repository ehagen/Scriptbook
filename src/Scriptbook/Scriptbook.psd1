@{
    RootModule        = 'Scriptbook.psm1'
    ModuleVersion     = '0.5.01'
    GUID              = '05a95b01-2890-480f-a4ac-f40bc52d6c82'
    Author            = 'Edwin Hagen'
    CompanyName       = 'Tedon Technology BV'
    Copyright         = '(c) Tedon Technology BV. All rights reserved.'
    Description       = 'Tedon Scriptbook Module'
    PowerShellVersion = '3.0'
    RequiredModules   = @()
    FunctionsToExport = @(
        'Action', 'Enable-Action', 'Disable-Action', 'Get-ActionReturnValue', 'Import-Action', 'Invoke-Action', 'Invoke-ScriptBlock', 'Register-Action', 'Reset-Workflow', 'Start-Scriptbook', 'Start-Workflow', 'Use-Workflow',
        'Get-DecryptedSecret', 'Get-EncryptedSecret', 'Get-LocalCredential', 'Assert-Condition', 'Assert-Version',
        'Get-BoundParametersWithDefaultValue', 'Set-EnvironmentVar', 'Get-EnvironmentVar', 'Test-PSProperty', 'Get-PSPropertyValue', 'Start-ShellCmd', 'Write-Info',
        'FormatTaskName', 'Include', 'Invoke-Psake', 'Invoke-Task', 'Properties', 'Start-PSakeWorkflow', 'Task', 'TaskSetup', 'TaskTearDown'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @(
        'Start-Flow', 'Start-Saga', 'Start-Pipeline', 'Saga', 'Flow', 'Pipeline', 'Step', 'Job', 'Test', 'Activity', 'Chore', 'Stage', 'Override', 'Info',
        'Documentation', 'Initialize-Action', 'Complete-Action', 'Import-Step', 'Import-Test', 'Invoke-Step', 'Execute', 'Exec', 'Assert', 'Get-ActionOutput', 'Get-ActionOutputValue'
    )
    PrivateData       = @{
        PSData = @{
            Tags         = @('Workflow', 'Scriptbook', 'Workbook', 'Runbook', 'Playbook')
            LicenseUri   = 'https://raw.githubusercontent.com/ehagen/Scriptbook/master/LICENSE'
            ProjectUri   = 'https://github.com/ehagen/Scriptbook'
            # IconUri = ''
            ReleaseNotes = 'https://github.com/ehagen/Scriptbook/docs/release-notes.md'
        }
    }
}