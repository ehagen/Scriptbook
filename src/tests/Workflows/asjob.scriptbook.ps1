Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Start {
    "In action: $($args.Name)"
    "In action: $($Name)"
}

Action Background -AsJob -Tag HelloBackground {
    "In background Action: $($args.ActionName) $($args.Tag)"
    "In background Action: $($ActionName) $($Tag)"
}

Action Repeater -for { @('one','two') } -AsJob {
    "In Repeater: item: $($args.ForItem); Action: $($args.Name)"
    "In Repeater: item: $($ForItem); Action: $($Name)"
}

Start-Workflow -Name AsJob