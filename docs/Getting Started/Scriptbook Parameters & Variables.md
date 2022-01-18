# Scriptbook Parameters and Variables

The default way of using parameters and variables in Scriptbook is the PowerShell way

## Parameters

In Scriptbook file you pass parameters to Workflow via Param block

```powershell
param(
    $ItemId,
    $ItemName,
    $ItemValue
)

# Sample usage parameters in Workflow
$myItemCaption = "$ItemName-$ItemId"
$myItemValue = $ItemValue

```

## Variables

In Scriptbook file you can use PowerShell variables in your Workflow

```powershell

$myItemCaption = "MyCaption"
$myItemValue = 100

```

## Access Parameters and Variables

Parameters and Variables are added to the file/script Scope and accessible via $Script:VarName or $varName when reading variable only

At file or script(book) level you can read and write to variables with the $myVar normal PowerShell syntax

At the Action level you can read variables with the $myVar syntax but modifying the variable requires script syntax --> $Script:myVar = 50

## Parameter and Variable naming conventions

It's custom for Parameters to use PascalCasing with where each word in the parameter starts with an UpperCase character like $ThisIsMyParamValue. Variable naming uses CamelCasing where each word in variable starts with UpperCase character except first character like $thisIsMyVarValue

## Passing parameters with PowerShell HashTables

Another way to pass parameters to Scriptbook is by using PowerShell HashTables @{}. This way you can pass easy a whole bunch of parameters and organize them in logical groups.

```powershell
param(
    $Item = @{ 
        Id = ''
        Name = ''
        Value = ''
    }
)

# Sample usage parameters in Workflow
$myItemCaption = "$($Item.Name)-$($Item.Id)"
$myItemValue = $Item.Value

```

## PowerShell Variable Scoping and PowerShell ScriptBlock

Scriptbook is a PowerShell DSL or as I would say Scriptbook is PowerShell in it's Core. That's why Scriptbook uses the same scoping rules as PowerShell.

References:

[About ScriptBlocks](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_script_blocks)
[About Parameters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameters)
[About Variables](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables)
[About Hash Tables](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables)
