param ($xmlFileName, $structureFileName)

if ( $null -eq $xmlFileName ) {
    $xmlFileName = read-host -Prompt "Please enter .xml source fileName" 
}   
if ( $null -eq $structureFileName ) {
    $structureFileName = read-host -Prompt "Please enter .csv target fileName" 
}   

function fillCSV
{
    param (
        $struct, $CSV
    )

    fillCSVHeader $CSV
    fillCSVData $struct $CSV
}
function fillCSVHeader
{
    param (
        $CSV
    )
    $lineNb = $CSV.Add("Level,TAG,Multiplicity,Type,Comments")
}
function fillCSVData {

    param (
        $struct, $CSV, [int]$level=1
    )

    if ($struct.Count -lt 1){
        #Nothing to add
    }
    else {
        foreach ($key in $struct.keys)
        {
            if ($key -ne "_Multiplicity")
            {
                if ([string]$struct[$key]["_Multiplicity"] -ne "")
                {
                    $lineNb = $CSV.Add([string]$level + "," + [string]$key + "," + [string]$struct[$key]["_Multiplicity"] + ",Element")
                }
                else
                {
                    $lineNb = $CSV.Add([string]$level + "," + [string]$key + ",0..1,Attribute")
                }
                fillCSVData $struct[$key] $CSV $($level+1)
            }
        }
    }
}

function fillStruct {
    param (
        $xmlNode, [hashtable]$struct = @{}
    )

    foreach($attribute in $xmlNode.Attributes)
    {
        [hashtable]$childStruct=@{}
        $key = $attribute.name

        if ( $struct.keys -contains $key )
        {
            
        }
        else 
        {
            $struct[$key] = @{}
        }
    }
    
    foreach($childNode in $xmlNode.ChildNodes)
    {
        [hashtable]$childStruct=@{}
        fillStruct $childNode $childStruct
        $key = $childNode.SchemaInfo.LocalName

        if ( $struct.keys -contains $key )
        {
            $childStruct.Add("_Multiplicity", "1..*")
            combineStruct $struct[$key] $childStruct
        }
        elseif ($childNode.NodeType -eq "Element") 
        {
            $childStruct.Add("_Multiplicity", "1")
            $struct[$key] = $childStruct
        }
    }
}

function combineStruct {
    param (
        [hashtable]$struct1, [hashtable]$struct2
    )

    foreach ($key in $struct2.keys)
    {
        if ($struct1.keys -contains $key)
        {
            if ($key -ne "_Multiplicity")
            {
                combineStruct $struct1[$key] $struct2[$key]
            }
            else 
            {
                $struct1[$key] = $struct2[$key]
            }
        }
        else
        {
            $struct1[$key] = $struct2[$key]
        }
    }
}

[xml]$XmlDocument = Get-Content -Path $xmlFileName
[System.Collections.ArrayList]$CSV= @()
$struct = @{}

fillStruct $XmlDocument $struct
fillCSV $struct $CSV

Set-Content -Path  $structureFileName -Value $null
$CSV | foreach { Add-Content -Path  $structureFileName -Value $_ }