# Scriptbook Workflow Context

A Scriptbook Workflow contains Data & Actions. Data is represented by parameters, variables, Files, streams and every other source available. Actions are represented by a PowerShell ScriptBlock which performs actions on the Data or with the Data. When your Scriptbooks or Workflows become very large or use a lot of data, organizing your parameters, variables and actions can be challenge. You can split your workflow in different files, organize them by action groups, put you parameters in separate pds1 or json files.

By introducing a Scriptbook Workflow Context you can organize your data parameters and variables. Added with additional loading and saving of the data.

```powershell
Initialize-Context -Name 'DefaultContext' -Path './DefaultContext.json' {
    @{
        Item   = @{
            Name = ''
            Id = ''
        }
        Store = @{
            Name        = ''
            SampleDatabase = ''
        }
    }
}
```
