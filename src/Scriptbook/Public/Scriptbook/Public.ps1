<#
.SYNOPSIS
Global function hooks which can be used at runtime to get more detailed information about the running workflow and actions

.DESCRIPTION
Global function hooks which can be used at runtime to get more detailed information about the running workflow and actions

#>

function Global:Invoke-BeforeWorkflow($Commands) { return $true }
function Global:Invoke-AfterWorkflow($Commands, $ErrorRecord) { }
function Global:Invoke-BeforePerform($Command) { return $true }
function Global:Invoke-AfterPerform($Command, $ErrorRecord) { }
function Global:Write-OnLog($Msg) {}
function Global:Write-OnLogException($Exception) {}

<#
.SYNOPSIS
DependsOn attribute to register function dependencies

.DESCRIPTION
DependsOn attribute to register function dependencies. Allows for using functions like Actions with dependency graph support.

.EXAMPLE

# implicit invokes function Invoke-Hello because function Invoke-Goodby is dependent on it

function Invoke-Hello
{
    Write-Info "Hello"
}

function Invoke-GoodBy
{
    [DependsOn(("Hello"))]param()
    Write-Info "GoodBy"
}

Start-Workflow Goodby

#>
class DependsOn : System.Attribute
{
    [string[]]$Name
    DependsOn([string[]]$name)
    {
        $this.Name = $name
    }
}
