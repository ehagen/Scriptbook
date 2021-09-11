<#
.SYNOPSIS
Get Credential from Local Credential cache in User profile on Windows.

.DESCRIPTION
Get Credential from Local Credential cache in User profile on Windows if found. Otherwise in interactive sessions Get-Credential is used to query for Credentials and store them in local cache encrypted.

.PARAMETER Name
Name of credential for reference only

#>
function Get-LocalCredential([Parameter(Mandatory = $true)][string]$Name)
{
    #TODO !!EH Windows Only or by design?
    $credPath = Join-Path $home "Cred_$Name.xml"
    if ( Test-Path $credPath )
    {
        $cred = Import-Clixml -Path $credPath
    }
    else
    {
        # not fail safe but better than nothing
        if ( ((Get-Host).Name -eq 'ConsoleHost') -and ([bool]([Environment]::GetCommandLineArgs() -like '-noni*')) )
        {
            Throw "Get-LocalCredential not working when running script in -NonInteractive Mode, unable to prompt for Credentials"
        }

        $parent = Split-Path $credPath -Parent
        if ( -not ( Test-Path $parent ) )
        {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        $cred = Get-Credential -Title "Provide '$Name' username/password"
        $cred | Export-Clixml -Path $credPath
    }
    return $cred
}