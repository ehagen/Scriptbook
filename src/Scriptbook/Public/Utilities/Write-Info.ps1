<#
.SYNOPSIS
Writes Info to console host.

.DESCRIPTION
Writes Info to console host.

.PARAMETER Object
Objects to display in the host.

.PARAMETER NoNewline
The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between the output strings. No newline is added after the last output string.

.PARAMETER Separator
Specifies a separator string to insert between objects displayed by the host.

.PARAMETER ForegroundColor
Specifies the text color.

.PARAMETER BackgroundColor
Specifies the background color.

#>
function Write-Info
{
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline = $True)]
        $Object,
        [switch]$NoNewline,
        $Separator,
        $ForegroundColor,
        $BackgroundColor
    )

    Begin
    {
        $parameters = @{ Object = $null }
        if ($NoNewline.IsPresent)
        {
            $parameters.Add('NoNewLine', $true)
        }
        if ($Separator)
        {
            $parameters.Add('Separator', $Separator)
        }
        # TODO !!EH Remap to ansi escape codes?
        if ($ForegroundColor)
        {
            $parameters.Add('ForegroundColor', $ForegroundColor)
        }
        if ($BackgroundColor)
        {
            $parameters.Add('BackgroundColor', $BackgroundColor)
        }
    }

    Process
    {
        $parameters.Object = $Object
        Write-Host @parameters        
    }

    End
    {
        [Console]::ResetColor()
    }
}