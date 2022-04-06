function New-SecureStringStorage
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    param([ValidateNotNullOrEmpty()]$String)

    return [SecureStringStorage]::New($String)
}