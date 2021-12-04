<#
.SYNOPSIS
Starts a shell command and waits for it to finish

.DESCRIPTION
Starts a shell command with arguments in working directory and waits for it to finish. Optionally supply credential under which execution will take place.

.PARAMETER Command
Name of executable to start

.PARAMETER Arguments
Arguments to pass to executable

.PARAMETER Credential
Credential to start process with

.PARAMETER WorkingDirectory
Working directory of executable

.PARAMETER NoOutput
Suppress output of executable

.PARAMETER EnvVars
Additionally supply environment variables to process

.OUTPUTS
Returns Process StdOut, StdErr and ExitCode

.EXAMPLE
Start-ShellCmd -Command 'cmd.exe' -Arguments '/c'

.EXAMPLE
$r = Start-ShellCmd -Command 'pwsh' -Arguments '-NonInteractive -NoLogo -OutputFormat Text -ExecutionPolicy Bypass -Command Get-Process'
if ($r.ExitCode -ne 0) { throw "Invalid ExitCode returned from pwsh.exe : $($r.ExitCode)"}

.EXAMPLE
Start-ShellCmd -c 'pwsh' -a '-Command Get-Service' | Out-Null

#>
function Start-ShellCmd
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [alias('c')]
        $Command,
        [alias('a')]
        $Arguments,
        [PSCredential]
        $Credential,
        [alias('w')]
        $WorkingDirectory = '',
        [alias('no')][switch]
        $NoOutput,
        $EnvVars,
        [switch]
        $Progress
    )

    try
    {
        $pInfo = New-Object System.Diagnostics.ProcessStartInfo
        $pInfo.FileName = $Command
        $pInfo.RedirectStandardError = $true
        $pInfo.RedirectStandardOutput = $true
        $pInfo.UseShellExecute = $false
        $pInfo.Arguments = $Arguments
        $pInfo.ErrorDialog = $false
        if ((!$WorkingDirectory) -or ($WorkingDirectory -eq ''))
        {
            $pInfo.WorkingDirectory = Get-Location
        }
        else
        {
            $pInfo.WorkingDirectory = $WorkingDirectory
        }
        if ($env:SystemRoot)
        {
            $pInfo.LoadUserProfile = $true
        }
        if ($Credential)
        {
            $pInfo.UserName = $Credential.GetNetworkCredential().UserName
            if ($Credential.GetNetworkCredential().Domain)
            {
                $pInfo.Domain = $Credential.GetNetworkCredential().Domain
            }
            $pInfo.Password = $Credential.GetNetworkCredential().SecurePassword
        }	
        if ($EnvVars)
        {
            foreach ($v in $EnvVars.GetEnumerator())
            {
                if ($v.Key) { $pInfo.EnvironmentVariables[$v.Key] = $v.Value; }
            }
        }
        if ($PSCmdlet.ShouldProcess('Start-ShellCmd'))
        {
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pInfo
            if ($Progress.IsPresent)
            {
                $stdOutBuilder = New-Object -TypeName System.Text.StringBuilder
                $stdErrBuilder = New-Object -TypeName System.Text.StringBuilder
                $eventHandler = `
                {
                    if (![String]::IsNullOrEmpty($EventArgs.Data))
                    {
                        $Event.MessageData.Builder.AppendLine($EventArgs.Data)
                        if ($Event.MessageData.ShowOutput)
                        {
                            Write-Host $EventArgs.Data
                        }
                    }
                }
                $mdo = [PSCustomObject]@{
                    ShowOutput = !($NoOutput.IsPresent)
                    Builder    = $stdOutBuilder
                }
                $mde = [PSCustomObject]@{
                    ShowOutput = !($NoOutput.IsPresent)
                    Builder    = $stdErrBuilder
                }
                $stdOutEvent = Register-ObjectEvent -InputObject $p -Action $eventHandler -EventName 'OutputDataReceived' -MessageData $mdo
                $stdErrEvent = Register-ObjectEvent -InputObject $p -Action $eventHandler -EventName 'ErrorDataReceived' -MessageData $mde
                $p.Start() | Out-Null
                $handle = $p.Handle # cache handle to prevent $null ExitCode issue
                $p.BeginOutputReadLine()
                $p.BeginErrorReadLine()
                While (-not ($p.HasExited))
                {
                    $p.Refresh()
                }
                Unregister-Event -SourceIdentifier $stdOutEvent.Name; $stdOutEvent = $null;
                Unregister-Event -SourceIdentifier $stdErrEvent.Name; $stdErrEvent = $null;
                $so = $stdOutBuilder.ToString().TrimEnd("`r", "`n");
                $se = $stdErrBuilder.ToString()
            }
            else
            {
                $p.Start() | Out-Null
                $handle = $p.Handle # cache handle to prevent $null ExitCode issue
                $so = $p.StandardOutput.ReadToEnd()
                $se = $p.StandardError.ReadToEnd()
                $p.WaitForExit()
                if (!($NoOutput.IsPresent)) { Write-Info "$so $se" }
            }
            Write-Debug "Start-ShellCmd: Process Handle: $handle"
            [PSCustomObject]@{
                StdOut   = $so
                StdErr   = $se
                ExitCode = $p.ExitCode
            }
            $handle = $null
        }
    }
    catch
    {
        if ($_.Exception.Message.Contains('The stub received bad data'))
        {
            Throw "No domain name specified, add domain name to user '$($pInfo.UserName)' : $($_.Exception.Message)"
        }
        else
        {
            Throw
        }
    }
}