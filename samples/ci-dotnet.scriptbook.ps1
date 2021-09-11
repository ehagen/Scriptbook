Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

$solutionLocation = Join-Path $PSScriptRoot 'tmp/MyConsoleApp/src'
New-Item -Path $solutionLocation -ItemType Directory -ErrorAction Ignore | Out-Null

Step CleanUp {
    # remove old version
    Remove-Item -Path (Join-Path $solutionLocation *) -Force -Recurse -ErrorAction Ignore
}

Step Initialize {
    $project = 'MyConsoleApp'
    Assert-Version -Command dotnet -Version 5.0 -Minimum
    # create solution and projects
    Execute { dotnet new console --name $project --output (Join-Path (Get-Location) $project) }
    Execute { dotnet new xunit --name "$project.Tests" --output (Join-Path (Get-Location) "$project.Tests") }
    Execute { dotnet new sln --name $project }
    Execute { dotnet sln add (Join-Path (Get-Location) $project) }
    Execute { dotnet sln add (Join-Path (Get-Location) "$project.Tests") }
}

Step Build -AsJob {
    Execute { dotnet build } -Message 'dotnet build'
}

Step Test -AsJob {
    Execute { dotnet test } -Message 'dotnet test'
}

Step Publish -AsJob {
    Execute { dotnet publish } -Message 'dotnet publish'
}

Step Validate -AsJob -Parameters @{SolutionLocation = $solutionLocation } {
    $dll = Join-Path $args.Parameters.SolutionLocation "MyConsoleApp/bin/Debug/net5.0/publish/MyConsoleApp.dll"
    $dll
    Assert-Condition (Test-Path $dll) "Unable to find executable library $dll"
}

# set path for each step
Set-Location $solutionLocation

Start-Workflow -Name ci