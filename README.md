# Scriptbook

Scriptbook is a cross platform PowerShell module to define your code as a Workflow. It's a way to structure your PowerShell script with Actions or Steps.

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/ehagen/Scriptbook/master/LICENSE)
![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Scriptbook.svg?label=PSGallery%20Version&logo=PowerShell&style=flat-square)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Scriptbook.svg?label=PSGallery%20Downloads&logo=PowerShell&style=flat-square)
[![Build Status](https://dev.azure.com/tedon/TD.Deploy/_apis/build/status/ehagen.Scriptbook?branchName=master)](https://dev.azure.com/tedon/TD.Deploy/_build/latest?definitionId=52&branchName=master)
[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/ehagen/scriptbook)


<p align="center">
  <a href="https://www.powershellgallery.com/packages/Scriptbook"><img src="https://img.shields.io/powershellgallery/p/Scriptbook.svg"></a>
  <a href="https://github.com/ehagen/Scriptbook"><img src="https://img.shields.io/github/languages/top/ehagen/Scriptbook.svg"></a>
  <a href="https://github.com/ehagen/Scriptbook"><img src="https://img.shields.io/github/languages/code-size/ehagen/Scriptbook.svg"></a>
</p>

## Features of Scriptbook include

- Define your Workflow in PowerShell
- Supports Sequential and Dependency based Workflows
- Allows for nested Actions
- Extent Workflow with your own Actions / Action Modules
- Use all the PowerShell and .Net features in your Workflows
- Test your Workflow in Test Mode with Test Actions
- Run and Debug your Workflow like a normal PowerShell script
- Document your Workflow

### Sample Workflow

```powershell
Import-Module Scriptbook

Action Hello {
    Write-Info "Hello"
}

Action GoodBy {
    Write-Info "GoodBy"
}

Start-Workflow -Name 'Hello-Workflow'
```

## Getting the Module

You can download and install the Scriptbook module from the PowerShell Gallery

```powershell
Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
```

## Getting started

> Ensure you have installed Scriptbook module

- Create new PowerShell script file: hello-workflow.ps1

- Import Scriptbook Module

```powershell
Import-Module Scriptbook
```

- Define you actions

```powershell
Action Hello {
    Write-Host "Hello"
}

Action GoodBy {
    Write-Host "GoodBy"
}
```

- Start your Workflow actions

```powershell
Start-Workflow -Name 'Hello-Workflow'
```

## Language reference

Scriptbook extends PowerShell with domain specific language (DSL) keywords and Commands.

## Keywords

The following language keywords are used by the Scriptbook module:

- Action - An Action definition / ScriptBlock
- Test - A Test definition / ScriptBlock
- Info - A Documentation definition / ScriptBlock

## Commands

The following commands exist in the Scriptbook module:

- Start-Workflow - Starts a workflow of Actions
- Enable-Action - Enables an action at runtime
- Disable-Action - Disables an action at runtime
- Invoke-Action - Invokes an action at runtime
- Import-Action - Import actions from another ps file
- Assert-Condition - Checks the supplied boolean condition/ScriptBlock

## Requirements

- PowerShell Core or
- PowerShell 5.1

## Contributing

This project welcomes contributions and suggestions.
If you are ready to contribute, please visit the [contribution guide](CONTRIBUTING.md).

## Code of Conduct

This project uses the following [Code of Conduct](CODE_OF_CONDUCT.md).

## Maintainers

- [Edwin Hagen](https://github.com/ehagen) Tedon Technology BV

## License

This project is [licensed under the MIT License](LICENSE).

## Dependencies

- Pester Module (Build only)
- PSScriptAnalyzer (Build only)
- platyPS (Build only)
- Docker (Optional at RunTime)

## Build and Test Scriptbook module from source

- Run the build.ps1 file from PowerShell console to create the module in the deploy folder and perform the tests from the src/tests folder with Pester

## Structure Scriptbook module sources

Scriptbook module contains private functions, public functions and Scriptbook Actions. The folder layout used within this git repo is:

- build
- deploy
- docs
- src
  - Scriptbook
    - Private
    - Public
    - Scriptbook.psd
    - Scriptbook.psm
  - tests
