# Release Notes

![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Scriptbook.svg?label=PSGallery%20Version&logo=PowerShell&style=flat-square)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Scriptbook.svg?label=PSGallery%20Downloads&logo=PowerShell&style=flat-square)
[![Build Status](https://dev.azure.com/tedon/TD.Deploy/_apis/build/status/ehagen.Scriptbook?branchName=master)](https://dev.azure.com/tedon/TD.Deploy/_build/latest?definitionId=52&branchName=master)

## [0.6.4] 2023-03-11

```plain
### Fixed
- Fixed docker volume mappings usage
- Added docker EnvVarPrefixes support

## [0.6.4] 2022-10-22

```plain
### Fixed
- Added parameters merge support by default, merges parameter values defined in script with values loaded from file
- Fixed NoLogging parameter of Start-Workflow in combination with Verbose usage
- Added secrets scanning during build of module

```

## [0.6.3]

```plain
### Fixed
- Fixed loading module-cache DataTime format different cultures issue


```

## [0.6.2]

```plain
### Added
- Added Out-Verbose alias to Out-ScriptbookVerbose

### Changed
- Changed alias Out-Null to Out-NullSb and always make sure no exceptions are thrown

```

## [0.6.1]

```plain
### Fixed
- Fixed Wrong file name function Out-ScriptbookVerbose
- Fixed Test Results report and Code Coverage report in Github Actions and Azure DevOps

```

## [0.6.0]

```plain
### Added

- Added Set-WorkflowInConfigureMode
- Added $ConfigurePreference & Edit Scriptbook parameters in Console Host (use -Configure parameter on Start-Scriptbook)
- Added AsJob support to Start-Scriptbook
- Added secure storage of secrets in json files to read/save parameters (from TD.Util)
- Added not (!) support to Action expansion
- Added warning loading Scriptbook module twice
- Added Get-IsPowerShellStartedInNonInteractiveMode (Check running in console mode)
- Added verbose support to Start-Workflow
- Added verbose support to Out-Null (visible when in verbose mode)

### Changed
- Updated to Pester 5.* with code-coverage

```

## [0.5.5]

```plain
### Added

- Added -Confirm support to Start-Workflow
- Added Scriptbook Workflow Variables
- Added Scriptbook Workflow Parameters
- Added Scriptbook Workflow Context
- Added Scriptbook Tests action
- Added Scriptbook Setup and Teardown actions
- Added indent-level to action output
- Added $_ variable support in Action For loop, alternative for $ForItem

### Changed

- Fixed -WhatIf precedence over -Confirm like PowerShell does in 'SupportsShouldProcess'
- Fixed workflow Transcript with -WhatIf
- Fixed loading Cache file DateTime on all PowerShell versions and Platforms
- Cleanup CallStack, removed ScriptBook/framework lines
- Refactored Pester tests

```

## [0.5.4]

```plain
### Added

- Added loading dependant modules from file path in Import-Module Scriptbook
- Added skipping action when Workflow is executed sequentially (extracted from sequence). Use -NoSequence switch on Action
- Added selecting 'Workflow Start Action' with wildcards, like Start-Workflow -Actions 'Hello*','Goodby*' or Start-Workflow -Actions *
- Added Action -Confirm switch support
- Added Action -WhatIf switch support
- Added Out-ScriptbookHost/Out-Info
- Added support for Simple Powershell Hosts which do not support ansi-escape codes (Azure Automation for example)

### Changed

- Renamed module cache file in $home to Scriptbook.ModuleCache.json
- Updated Workflow Report with display of Skipped actions

```

## [0.5.3]

```plain
### Fixed

- Fixed double load module by removing internal reference

```

## [0.5.2]

```plain
### Added

- Added Workflow Notification (only console for now)
- Added Start-Workflow ErrorAction variable support
- Added PreviousRunContext

### Fixed

- Fixed loading Cache file DateTime on all PowerShell versions and Platforms

```

## [0.5.1]

```plain
### Added

- Added Action Always support
- Added Start-Workflow ErrorAction variable support
- Added Get-ActionState
- Added skipPublisherCheck support to Import-Module
- Added Get-EnvironmentVar
- Added Test-PSProperty
- Added Get-PSProperty

### Changed

- Cleanup Workflow Report dependencies

```

## [0.5.0]

```plain
### Added

- Initial version
```

The format is based on [Keep a Changelog](http://keepachangelog.com/)