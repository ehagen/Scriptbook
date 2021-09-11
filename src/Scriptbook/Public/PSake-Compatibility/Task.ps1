# compatibility with PSake
function Task
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string] $Name,
        [String[]] $Tag = @(),
        [String[]] $Depends = @(),
        $Parameters = @{},
        [Switch]$AsJob,
        [String]$Description,
        [ScriptBlock]$PreCondition = { $true },
        [ScriptBlock]$PostCondition, # not implemented
        [Switch]$ContinueOnError,
        [String]$FromModule,
        [Parameter(Position = 1)]
        [ScriptBlock] $Code
    )

    $lName = $Name -replace 'Invoke-', ''
    if ($FromModule)
    {
        if (!($taskModule = Get-Module -Name $FromModule))
        {
            $taskModule = Get-Module -Name $FromModule -ListAvailable -ErrorAction Ignore -Verbose:$False | Sort-Object -Property Version -Descending | Select-Object -First 1
        }
        $psakeFilePath = Join-Path -Path $taskModule.ModuleBase -ChildPath 'psakeFile.ps1'
        if (Test-Path $psakeFilePath)
        {
            . $psakeFilePath
        }
    }
    else
    {
        if ($lName -ne 'Default' -and $lName -ne '.' )
        {
            if ($null -eq $Code)
            {
                Write-Verbose "Task: $lName No code script block is provided. (Have you put the open curly brace on the next line?)"
                $Code = {}
            }
            if ($null -ne $PostCondition)
            {
                Write-Warning "Post Condition not implemented"
            }
            $eaValue = 'Stop'
            if ($ContinueOnError.IsPresent)
            {
                $eaValue = 'Ignore'
            }
            Register-Action -Name $Name -Tag $Tag -Depends $Depends -Parameters $Parameters -AsJob:$AsJob.IsPresent -If $PreCondition -ErrorAction $eaValue -Description $Description -Code $Code -TypeName Task
        }
    }

    # start build-in Action: Start Workflow
    if ($lName -eq 'Default' -or $lName -eq '.')
    {
        Start-Workflow -Actions $Depends -Parameters $Parameters -Location (Get-Location)
    }
}