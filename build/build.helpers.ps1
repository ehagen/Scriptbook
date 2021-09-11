function Show-PesterOutput($PesterResult)
{
    function Show-PesterStandardOutput($block)
    {
        if ($block.Blocks)
        {
            foreach ($b in $block.Blocks)
            {
                Show-PesterStandardOutput($b)
            }    
        }
        else
        {
            foreach ($t in $block.Tests)
            {
                if ($t.StandardOutput)
                {
                    if ($t.Result -eq 'Failed')
                    {
                        Write-Info "-Error in test ===================================================================" -ForegroundColor Cyan
                    }
                    foreach ($l in $t.StandardOutput)
                    {
                        Write-Info "[Test Output] $l"
                    }
                    if ($t.Result -eq 'Failed')
                    {
                        Write-Info "-Error in test ===================================================================" -ForegroundColor Cyan
                    }
                }
            }
        }
    }

    foreach ($c in $PesterResult.Containers)
    {
        foreach ($b in $c.Blocks)
        {
            Show-PesterStandardOutput($b)
        }
    }
}