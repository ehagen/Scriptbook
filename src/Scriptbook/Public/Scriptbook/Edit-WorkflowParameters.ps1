<#
.SYNOPSIS
Edit the workflow parameters defined in the workflow via the host console

.DESCRIPTION
Edit the workflow parameters defined in the workflow via the host console. 

.PARAMETER Name
Name of the Parameters Set

.PARAMETER Path
Storage location of Parameters values in json format

.PARAMETER Notice
Message to show in Console Host before getting values from user

#>
function Edit-WorkflowParameters
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param($Name, $Path, $Notice)

    Read-ParameterValuesFromHost -Name $Name -Notice $Notice
    if ($null -ne $Path)
    {
        Save-ParameterValues -Name $Name -Path $Path
    }
}