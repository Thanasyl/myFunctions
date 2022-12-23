param ($xmlFileName, $structureFileName)

if ( $null -eq $xmlFileName ) {
    $xmlFileName = read-host -Prompt "Please enter .xml source fileName" 
}   
if ( $null -eq $structureFileName ) {
    $structureFileName = read-host -Prompt "Please enter .csv target fileName" 
}   

[xml]$XmlDocument = Get-Content -Path $xmlFileName
[System.Collections.ArrayList]$outPutFileContent= @()

function fillTxt {

    param (
        $struct, $outPutFileContent, [int]$level=1
    )

    if ($struct.Count -lt 1){
        #Nothing to add
    }
    else {
        foreach ($key in $struct.keys)
        {
            if ($key -ne "#text")
            {
                $lineNb = $outPutFileContent.Add([string]$level + "," + [string]$key)
                fillTxt $struct[$key] $outPutFileContent $($level+1)
            }
        }
    }
}

function fillStruct {
    param (
        $xmlNode, [hashtable]$struct = @{}
    )
    
    foreach($childNode in $xmlNode.ChildNodes)
    {
        [hashtable]$childStruct=@{}
        fillStruct $childNode $childStruct

        if ( $struct.keys -contains $childNode.Name ){
            combineStruct $struct[$childNode.Name] $childStruct
        }
        else {
            $struct[$childNode.Name] = $childStruct
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
            combineStruct $struct1[$key] $struct2[$key]
        }
        else {
            $struct1[$key] = $struct2[$key]
        }
    }
}

$struct = @{}
fillStruct $XmlDocument $struct
fillTxt $struct $outPutFileContent

Set-Content -Path  $structureFileName -Value $null
$outPutFileContent | foreach { Add-Content -Path  $structureFileName -Value $_ }