<#
.SYNOPSIS
Encrypts secret with Seed value

.DESCRIPTION
Encrypts secret with Seed value. Seed complexity is 
    - At least one upper case letter [A-Z]
    - At least one lower case letter [a-z]
    - At least one number [0-9]
    - At least one special character (!,@,%,^,&,$,_)
    - Password length must be 7 to 25 characters.
.PARAMETER Value
Value to encrypts

.PARAMETER Seed
Seed value used to encrypts value
#>
function Get-EncryptedSecret
{
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [alias('v')]
        $Value,
        [ValidateNotNullOrEmpty()]
        [ValidateLength(8, 1024)]
        [ValidatePattern('^((?=.*[a-z])(?=.*[A-Z])(?=.*\d)|(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9])|(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9])|(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]))([A-Za-z\d@#$%^&amp;£*\-_+=[\]{}|\\:();!]|\.(?!@)){8,16}$')]
        [alias('s', 'k', 'Key')]
        $Seed
    )

    $hash = (New-Object System.Security.Cryptography.SHA256CryptoServiceProvider).ComputeHash(([system.Text.Encoding]::Unicode).GetBytes($Seed));
    $iv = New-Object byte[] 16;
    $key = New-Object byte[] 16;
    [System.Buffer]::BlockCopy($hash, 0, $key, 0, $key.Length)
    $encryptor = ([System.Security.Cryptography.AesCryptoServiceProvider]::Create()).CreateEncryptor($key, $iv)
    $buffer = [System.Text.Encoding]::Unicode.GetBytes($Value);
    $encryptedBlob = $encryptor.TransformFinalBlock($buffer, 0, $buffer.Length);
    
    return [System.Convert]::ToBase64String($encryptedBlob)
}