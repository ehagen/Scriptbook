[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
class SecureStringStorage
{
    hidden [String] $String
    [String] $TypeName = 'SecureStringStorage'

    SecureStringStorage($String)
    {
        if (($String -is [PSCustomObject]) -and ($String.TypeName -eq 'SecureStringStorage') )
        {
            $this.String = $String.String
        }
        elseif (($String -is [SecureString]))
        {
            $this.String = $String | ConvertFrom-SecureString
        }
        else
        {
            $this.String = ConvertTo-SecureString -String $String -AsPlainText -Force | ConvertFrom-SecureString
        }
    }

    [string]ToString()
    {
        return $this.String
    }

    [SecureString]GetSecureString()
    {
        $secureString = ConvertTo-SecureString -String $this.String -Force
        return $secureString
    }

    [string]GetPlainString()
    {
        $plain = ConvertTo-SecureString -String $this.String -Force | ConvertFrom-SecureString -AsPlainText
        return $plain
    }
}