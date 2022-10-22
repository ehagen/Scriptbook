param(
    $Actions,
    [switch]$Publish
)

Set-Location $PSScriptRoot

Import-Module ../src/Scriptbook/Scriptbook.psm1 -Force -Args @{ 
    Quiet   = $false
    Reset   = $false
    Verbose = $false
    Depends = @(
        @{
            Module         = 'Pester'
            MinimumVersion = '5.0'
            MaximumVersion = '5.9'
            Force          = $false
            Args           = @{ Quiet = $true } 
        },
        @{
            Module = 'PSScriptAnalyzer'
        },
        @{
            Module = 'TD.Util'
        },
        @{
            Module = 'platyPS' 
        },
        @{
            Module = 'PSSecretScanner'
        }        
    ) 
}

$parameters = @{ Actions = $Actions; Publish = $Publish.IsPresent }

# via dot sourcing only for build self
. ./build.scriptbook.ps1 @parameters