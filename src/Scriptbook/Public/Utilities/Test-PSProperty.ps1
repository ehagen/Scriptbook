<#
.SYNOPSIS
Checks if property exists on Object 

.DESCRIPTION
Checks if property exists on Object. In Set-StrictMode -Latest every property used is checked for existence --> runtime exception

.PARAMETER Object
Object to test for property

.PARAMETER Name
Name of property

.PARAMETER Exact
Use exact match in property name checking

#>
function Test-PSProperty
{
    param([alias('o')][object]$Object, [alias('p')][string]$Name, [alias('e')][switch]$Exact)

    try
    {
        foreach ($prop in $Object.PSObject.Properties)
        {
            if ($Exact.IsPresent)
            {
                if ($prop.Name -eq $Name)
                {
                    return $true
                }
                elseif ($prop.Name -match 'Keys')
                {
                    if ($prop.Value -eq $Name)
                    {
                        return $true
                    }
                }
            }
            else
            {
                if ($prop.Name -match $Name)
                {
                    return $true
                }
                elseif ($prop.Name -match 'Keys')
                {
                    if ($prop.Value -match $Name)
                    {
                        return $true
                    }
                }
            }
        }
    }
    catch
    {
        # not found
    }
    return $false
}