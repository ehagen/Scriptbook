Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Start {
    Write-Info $args.Name
}

Action RepeaterNumbers -For { 1..3 } -AsJob {
    Write-Info "ForItem: $ForItem or `$_: $_"
    Write-Info "Name: $Name"
    $ForItem
}

$items = @('one', 'two')

Action RepeaterItems -For { $items } -Parameters @{MyName = 'MyFirstName'} {
    Write-Info "ForItem: $ForItem or `$_: $_"
    Write-Info "Name: $Name"
    Write-Info "MyName: $($Parameters.MyName)"
    $ForItem
}

Action NoRepeat {
    Write-Info 'No repeat'
}

Start-Workflow -Name ForLoop