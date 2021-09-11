Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

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