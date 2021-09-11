Set-Location $PSScriptRoot

. ../../Scriptbook/Public/Utilities/Start-ShellCmd.ps1 -Force

$files = Get-ChildItem *.ps1 -Exclude 'run-workflows.ps1', 'hallo-test-02.actions.ps1', 'nested-02.scriptbook.ps1', 'nested-03.scriptbook.ps1', 'nested-04.scriptbook.ps1'

$errors = @()
foreach ($f in  $files)
{
    Write-Host "--Starting $($f.Name)"
    try
    {
        # run in separate process to prevent side effects
        $r = Start-ShellCmd -Command 'pwsh' -Arguments "-NonInteractive -NoLogo -OutputFormat Text -ExecutionPolicy Bypass -File $($f.FullName)" -Progress

        # validate
        if ($r.ExitCode -ne 0) { throw "Invalid ExitCode returned from pwsh.exe in run-samples '$($f.Name)': $($r.ExitCode)" }
        if (![string]::IsNullOrEmpty($r.StdErr)) { throw "Errors found in output pwsh command in run-samples '$($f.Name)'" }

        # all workflows have output
        if ([string]::IsNullOrEmpty($r.StdOut)) { throw "No output found in pwsh command in run-samples '$($f.Name)'" }
    }
    catch
    {
        Write-Warning $_.Exception
        $errors = $errors + @{Exception = $_.Exception; File = $f.name }
    }
    Write-Host "--Finished $($f.Name)"
}

foreach ($err in $errors)
{
    Write-Host "ERROR:============================================================="
    Write-Host "Error in '$($err.File)' : $($err.Exception)"
}

if ($errors.Count -gt 0)
{
    throw "Errors occurred in running workflows, see log for more details"
}
else
{
    Write-Host "Finished running workflows flawless"
}