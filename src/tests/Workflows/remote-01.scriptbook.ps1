Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

$myGlobalVar = 'HelloFromGlobalVar'

if ($IsWindows)
{
    # handle loading cred
    $pso = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Culture 'en-US' -UICulture 'en-US' -ApplicationArguments @{IsScriptbook = $true }
    $sessionParameters = @{}
    #$sessionParameters.Add('UseSSL', $true)
    $sessionParameters.Add('Credential', (Get-LocalCredential -Name Localhost))
    $session = @(
        (New-PSSession -ComputerName Localhost @sessionParameters -EnableNetworkAccess -SessionOption $pso),
        (New-PSSession -ComputerName Localhost @sessionParameters -EnableNetworkAccess -SessionOption $pso)
    )
}
else
{
    # TODO !!EH: not tested yet
    return

    $sessionParameters = @{}   
    # issue: transmit password via parameters, now prompt for password. Work-around: use key-file via ssh-keygen
    # issue: remote session culture: no en-US
    $sessionParameters.Add('UserName', $env:USER)
    #$sessionParameters.Add('KeyFilePath', $KeyFile)
    $session = New-PSSession -HostName Localhost -SSHTransport @sessionParameters
}

Action Hello -Session $session {
    Write-Host "Hello: $($PSSenderInfo.ApplicationArguments.IsScriptbook)"
    Write-Host "User: $($PSSenderInfo.UserInfo.Identity.Name)"
    Write-Host "GlobalVar: $myGlobalVar"
}

Action GoodBy -Session $session -Isolated {
    Write-Host "GoodBy: $($PSSenderInfo.ApplicationArguments.IsScriptbook)"
    Write-Host "GlobalVar: $myGlobalVar"
}

Start-Workflow -Name Remote