Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

Action Start {
    Write-Info $args.Name
}

Action RepeaterNumbers -For { 1..3 } {
    Write-Info "ForItem: $ForItem"
    Write-Info "Name: $Name"
}

$items = @('one', 'two')

Action RepeaterItems -For { $items } -Parameters @{MyName = 'MyFirstName'} {
    Write-Info "ForItem: $ForItem"
    Write-Info "Name: $Name"
    Write-Info "MyName: $($Parameters.MyName)"
}

Action NoRepeat {
    Write-Info 'No repeat'
}

Start-Workflow -Name ForLoop