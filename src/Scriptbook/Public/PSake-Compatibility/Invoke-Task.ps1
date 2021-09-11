function Invoke-Task([Parameter(Mandatory = $true)]$TaskName)
{
    Invoke-PerformIfDefined -Command "Action-$TaskName" -ThrowError $true -Manual
}