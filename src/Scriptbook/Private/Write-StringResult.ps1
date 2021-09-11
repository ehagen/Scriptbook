function Write-StringResult($Result)
{
    if ($Result -is [array])
    {
        foreach ($l in $Result)
        {
            Write-Info $l
        }
    }
    else
    {
        Write-Info $Result
    }
}
