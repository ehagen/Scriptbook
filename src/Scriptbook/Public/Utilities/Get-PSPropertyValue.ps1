<#
.SYNOPSIS
Gets property value from Object

.DESCRIPTION
Gets property value from Object, first checks if property exists, if not returns default value. In Set-StrictMode -Latest every property used is checked for existence --> runtime exception

.PARAMETER Object
Object to get property value from

.PARAMETER Name
Name of property

.PARAMETER Default
Default value if property does not exists

#>
function Get-PSPropertyValue
{
    param([alias('o')][object]$Object, [alias('p')][string]$Name, [alias('d')]$Default = '')

    if (Test-PSProperty -o $Object -p $Name -Exact)
    {
        return $Object."$Name"
    }
    else
    {
        return  $Default
    }
}
