function Test-IsSecureStringStorageObject([ValidateNotNull()]$Object)
{
    return ($Object -is [SecureStringStorage])
}