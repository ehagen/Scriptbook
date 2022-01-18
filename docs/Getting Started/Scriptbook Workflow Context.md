# Scriptbook workflow context for parameters and variables

A Scriptbook Workflow contains Data & Actions. Data is represented by parameters, variables, files, streams and every other source available. Actions are represented by a PowerShell ScriptBlock which performs actions on or with that Data. When your Scriptbook workflows becomes very large, organizing your parameters, variables and actions can be challenging. You can split your workflow in different files by putting your actions, parameters & variables in separate .ps1 files.

By introducing Scriptbook Workflow Parameters & Variables functions you can organize your parameters and variables easier and have support for loading and saving parameter values to a file. The state of your Parameters and Variables are stored in the workflow context during the execution of your Scriptbook workflow.

```powershell
Parameters -Name 'DefaultParameters' -Path './DefaultParameters.json' {
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

# Get parameter values

$Context.DefaultParameters.Item.Name
# or
$Context.DefaultParameters.Store.Name

or

$ctx = Get-WorkflowContext
$ctx.DefaultParameters.Store.Name

```
