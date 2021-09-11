Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Start {
    Write-Info $args.Name
}

$globalVar = 'HelloFromGlobal'

Action RepeaterNumbers -For {1..3} -Parallel {
    Write-Info $args.ForItem
    Write-Info $args.Name
    Write-Info "ForItem: $ForItem"
    Write-Info "ForParallel: $ForParallel"
    Write-Info "Name: $Name"
    Write-Info "ActionName: $ActionName"
    Write-Info "GlobalVar: $globalVar"
    if ($args.ForParallel)
    {
        Start-Sleep -Seconds (Get-Random 3)
    }
    $args.ForItem
}

$items = @('one','two')

Action RepeaterItems -For { $items } -Parallel -Isolated {
    Write-Host $args.ForItem
    Write-Host $args.Name
    Write-Host "GlobalVar(Is Empty): $globalVar"
    $args.ForItem
}

Start-Workflow -Name Parallel