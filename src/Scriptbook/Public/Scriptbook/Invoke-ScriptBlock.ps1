<#
.SYNOPSIS
Executes a ScriptBlock with commands

.DESCRIPTION
Executes a ScriptBlock with commands. If ScriptBlock contains native commands LastExitCode is checked.

.PARAMETER ScriptBlock
The scriptblock with commands to execute

.PARAMETER Message
The message to display when command fails. Use it to hide secrets or long cmd lines.

.PARAMETER Location
Current Location or working directory of command

.PARAMETER IgnoreExitCode
Ignores the LastExitCode check

.PARAMETER AsJson
Return result as Json Object if possible

.EXAMPLE
Execute { cmd.exe /c }

.EXAMPLE
Invoke-ScriptBlock { cmd.exe /c } -Message 'cmd' -Location c:\ -IgnoreExitCode

#>
Set-Alias -Name Execute -Value Invoke-ScriptBlock -Scope Global -Force -WhatIf:$false
Set-Alias -Name Exec -Value Invoke-ScriptBlock -Scope Global -Force -WhatIf:$false
function Invoke-ScriptBlock
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0)][Scriptblock]
        $ScriptBlock,
        [alias('m')]
        [string][ValidateNotNullOrEmpty()]
        $Message,
        [alias('wd', 'WorkingDirectory')][ValidateNotNullOrEmpty()]
        $Location,
        [switch]$IgnoreExitCode,
        [switch]$AsJson
        #,[string]$Image # run in container image, TODO !!EH Mem, Cpu, disk, returns out-files/volume
    )

    function ConvertFrom-JsonInternal
    {
        [CmdletBinding()]
        param(
            [Parameter(ValueFromPipeline)] [string] $line
        )
        begin
        {
            $lines = [System.Collections.ArrayList]@()
        }
        process
        {
            [void]$lines.Add($line)
        }
        end
        {
            # only valid json passes, otherwise return original stream as strings
            try
            {
                return  $lines | ConvertFrom-Json
            }
            catch
            {
                return $lines | ConvertTo-String
            }
        }
    }
    
    # prevent accidental scope name collision
    $internalMessage = $Message
    Remove-Variable -Name Message -Scope Local
    $internalLocation = $Location
    Remove-Variable -Name Location -Scope Local
    $internalScriptBlock = $ScriptBlock
    Remove-Variable -Name ScriptBlock -Scope Local

    Write-Verbose "Start Executing $internalMessage"

    if (-not $PSCmdlet.ShouldProcess($internalLocation))
    {
        return
    }

    if ($internalLocation)
    {
        Push-Location $internalLocation
    }
    try
    {
        $Global:LastExitCode = 0
        # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.1
        #. $internalScriptBlock # current scope == module scope for functions in modules (scripts are in user scope)
        # current scope == child scope
        if ($AsJson.IsPresent)
        {
            Invoke-Command -ScriptBlock $internalScriptBlock | ConvertFrom-JsonInternal
        }
        else
        {
            Invoke-Command -ScriptBlock $internalScriptBlock
        }
        [Console]::ResetColor() # some programs mess this up
        if ( ($Global:LastExitCode -ne 0) -and !$IgnoreExitCode.IsPresent )
        {
            # to prevent secret leaks use Message parameter in commands to hide secrets/passwords
            $msg = $internalMessage
            if (!$msg) { $msg = $internalScriptBlock.ToString() }
            Throw "Executing $msg failed with exit-code $($Global:LastExitCode)"
        }
    }
    finally
    {
        if ($internalLocation)
        {
            Pop-Location
        }
        Write-Verbose "Finish Executing $internalMessage"
    }
}
