@{ 
    Quiet     = $false
    Reset     = $false
    Depends   = @(
        @{
            Module         = 'TD.Util'
            MinimumVersion = '0.1.10';
            Force          = $false
            Args           = @{ Quiet = $true } 
        }) 
    variables = @{
        HelloFromConfigure  = 'Hello From configure at startup'
        GoodbyFromConfigure = 'Goodby From configure at startup'
    }
}