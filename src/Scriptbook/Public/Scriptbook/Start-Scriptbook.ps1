function Global:Start-Scriptbook
{
    param(
        $File,
        $Actions,
        $Parameters,
        [switch]$Container,
        [HashTable]$ContainerOptions = @{}
    )

    if ($Container.IsPresent -or ($ContainerOptions.Count -gt 0) -and !$env:InScriptbookContainer)
    {
        Start-ScriptInContainer -File $Script:MyInvocation.ScriptName -Options $ContainerOptions -Parameters $Parameters
        return
    }
    else
    {
        . $File -Actions $Actions -Parameters $Parameters
    }
} 