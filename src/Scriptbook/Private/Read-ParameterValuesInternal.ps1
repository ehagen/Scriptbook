function Read-ParameterValuesInternal
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
        [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        $Path
    )

    $result = @{}
    $result = Get-Content -Path $Path | ConvertFrom-Json

    function Set-Props
    {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
        param($Object)
        
        foreach ($prop in $Object.PsObject.Properties)
        {
            if ($prop.Value -is [HashTable])
            {
                if ($prop.Value.ContainsKey('TypeName') -and ($prop.Value.TypeName -eq 'SecureStringStorage') )
                {
                    $prop.Value = [SecureStringStorage]$prop.Value
                }
            }
            elseif ($prop.Value -is [PSCustomObject])
            {
                if ($prop.Value.TypeName -and ($prop.Value.TypeName -eq 'SecureStringStorage') )
                {
                    $prop.Value = [SecureStringStorage]$prop.Value
                }
                else
                {
                    Set-Props $prop.Value
                }
            }
        }
    }
    
    # fix SecureString references
    Set-Props $result
    
    $ht = [ordered]@{}
    foreach ($prop in $result.PSObject.Properties.Name )
    {
        [void]$ht.Add($prop, $result.$prop)
    }
    
    return $ht
}