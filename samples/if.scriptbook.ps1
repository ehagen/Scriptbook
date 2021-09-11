Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

Action Hello {
    Write-Info $args.Name
    $script:SayGoodby = $false
}

Action GoodBy -If { $script:SayGoodby } {
    Write-Info $args.Name
}

Action Hello2 {
    Write-Info $args.Name
    $script:SayGoodby = $true
}

Action GoodBy2 -If { $script:SayGoodby } {
    Write-Info $args.Name
}

Start-Workflow -Name If