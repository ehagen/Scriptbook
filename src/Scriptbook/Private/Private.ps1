$ErrorActionPreference = 'Stop';

function InternalForceCultureEnglish
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
    param()

    try { [CultureInfo]::CurrentCulture = 'en-US' } catch {}
}

# default
InternalForceCultureEnglish

function Get-TempPath()
{
    if ( $env:TEMP ) { return ([System.IO.DirectoryInfo]$env:TEMP).FullName } else { return '/tmp' }
}

function Test-FileLocked([alias('p')][parameter(Mandatory = $true)]$Path)
{
    $f = New-Object System.IO.FileInfo $Path
    if ((Test-Path -Path $Path) -eq $false)
    {
        return $false
    }
    try
    {
        $oStream = $f.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        if ($oStream)
        {
            $oStream.Close()
        }
        return $false
    }
    catch
    {
        # file is locked by a process.
        return $true
    }
}


function Get-GlobalVarsForScriptblock
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param([switch]$Isolated, [switch]$AsUsing, [switch]$AsHashTable)

    if ($Isolated.IsPresent)
    {
        if ($AsHashTable.IsPresent)
        {
            return @{}
        }
        else
        {
            return ''
        }
    }

    if ($AsHashTable.IsPresent)
    {
        $result = @{}
        Get-Variable -Scope Global | ForEach-Object {
            if ( (!$Global:GlobalVarNames.ContainsKey($_.Name)) -and (!($_.Name.StartsWith('_'))) )
            {
                [void]$result.Add($_.Name, $_.Value)
            } 
        }
    }
    elseif ($AsUsing.IsPresent)
    {
        [string]$result = Get-Variable -Scope Global | ForEach-Object {
            if ( (!$Global:GlobalVarNames.ContainsKey($_.Name)) -and (!($_.Name.StartsWith('_'))) )
            {
                "`$$($_.Name) = `$using:$($_.Name); "
            } 
        }
    }
    else
    {
        # TODO !!EH Issue with $null values and PSCustomObjects, don't work with .ToString()...
        # reformat via ast
        # create scriptblock from string with Set-Variable 'Name' -Value $null
        # parse scriptblock with ast and set value of var
        [string]$result = Get-Variable -Scope Global | ForEach-Object {
            if ( (!$Global:GlobalVarNames.ContainsKey($_.Name)) -and (!($_.Name.StartsWith('_'))) )
            {
                if ($null -eq $_.Value)
                {
                    "Set-Variable '$($_.Name)' -Value `$null ; "
                }
                elseif ($_.Value -is [string])
                {
                    "Set-Variable '$($_.Name)' -Value '$($_.Value)' ; "
                }
                elseif ($_.Value -is [array])
                {
                    # not working yet array to string
                    "Set-Variable '$($_.Name)' -Value '$($_.Value)' ; "
                }
                elseif ($_.Value -is [PSCustomObject] )
                {
                    # for now, figure out $v.ToString()...
                    "Set-Variable '$($_.Name)' -Value `$null ; "
                }
                else
                {
                    "Set-Variable '$($_.Name)' -Value $($_.Value) ; "
                }
            } 
        }
    }
    return $result
}

function Write-ExceptionMessage([alias('e')]$ErrorRecord, [alias('f')][switch]$Full = $false, [alias('tlc')]$TraceLineCnt = 0)
{
    if (($VerbosePreference -eq 'Continue') -or $Full.IsPresent)
    {
        Write-Info ($ErrorRecord | Format-List * -Force | Out-String) -ForegroundColor White -BackgroundColor Red
    }
    else
    {
        Write-Info ''
        Write-Info 'Error:'.PadRight(78, ' ') -ForegroundColor White -BackgroundColor Red
        Write-Info $ErrorRecord.Exception.Message -ForegroundColor Red
        if ($TraceLineCnt -ne 0)
        {
            $cnt = 0;
            Write-Info ''
            Write-Info 'CallStack:'.PadRight(78, ' ') -ForegroundColor Black -BackgroundColor Yellow
            foreach ($line in $ErrorRecord.ScriptStackTrace.Split("`n"))
            {
                Write-Info $line -ForegroundColor Yellow
                $cnt++
                if ($cnt -ge $TraceLineCnt) { break; }
            }            
            Write-Info ''
        }
    }
}

function Write-Experimental($Msg)
{
    Write-Warning "Experimental: $Msg"
}

function Write-Unsupported($Msg)
{
    Write-Warning "Unsupported: $Msg"
}

function Get-CommentFromCode($ScriptBlock, $Script, $File, [int]$First = -1, [switch]$IncludeLineComments)
{
    $text = $null
    $tokens = $errors = $null
    if ($ScriptBlock)
    {
        [System.Management.Automation.Language.Parser]::ParseInput($ScriptBlock.ToString(), [ref]$tokens, [ref]$errors) | Out-Null
    }
    elseif ($Script)
    {
        [System.Management.Automation.Language.Parser]::ParseInput($Script, [ref]$tokens, [ref]$errors) | Out-Null
    }
    elseif ($File)
    {
        [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$tokens, [ref]$errors) | Out-Null
    }
    else
    {
        Throw "Get-CommentFromCode: No input supplied"
    }

    $maxTokens = $First
    $cntTokens = 0
    foreach ($token in $tokens )
    {
        if ($token.Kind -eq 'comment')
        {
            if ($token.Text)
            {
                if ($token.Text.StartsWith('#') -and !$IncludeLineComments.IsPresent)
                {
                    continue;
                }
                $txt = $token.Text -Split "`n"
                if ($txt.Length -gt 1)
                {
                    # get indent from last line and strip
                    $indent = $txt[$txt.Length-1].TrimEnd('#>');
                    if ($indent.Length -gt 0) 
                    {
                        $txt = $txt | ForEach-Object { $_.TrimStart($indent) }
                    }
                    $text += $txt | Select-Object -Skip 1 -First ($txt.Count - 2) -ErrorAction Ignore
                }
                else
                {
                    if ($txt.StartsWith('#'))
                    {
                        $text += $txt.TrimStart('# ') + "`n"
                    }
                    else
                    {
                        $text += $txt.TrimStart('<#').TrimEnd('#>') + "`n"
                    }
                }
            }
        }
        $cntTokens++
        if ( ($maxTokens -ne -1) -and ($cntTokens -ge $maxTokens) )
        {
            break
        }
    }
    return $text
}