# Release Notes

![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Scriptbook.svg?label=PSGallery%20Version&logo=PowerShell&style=flat-square)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Scriptbook.svg?label=PSGallery%20Downloads&logo=PowerShell&style=flat-square)
[![Build Status](https://dev.azure.com/tedon/TD.Deploy/_apis/build/status/ehagen.Scriptbook?branchName=master)](https://dev.azure.com/tedon/TD.Deploy/_build/latest?definitionId=52&branchName=master)

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