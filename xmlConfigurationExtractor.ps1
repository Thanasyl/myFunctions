param ($xmlFileName='.\TestData\basicXml.xml', $structureFileName='.\TestData\basicXmlStructure.csv')

if ($xmlFileName -eq $null) {
    $xmlFileName = read-host -Prompt "Please enter an xmlFileName" 
}   

[xml]$XmlDocument = Get-Content -Path $xmlFileName
[System.Collections.ArrayList]$outPutFileContent= @()

function fillTxt {

    param (
        $struct, $outPutFileContent, [int]$level=1
    )

    if ($struct.Count -lt 1){
        #$outPutFileContent.Add([string]$level + ";" + [string]$xmlNode.Name) 
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