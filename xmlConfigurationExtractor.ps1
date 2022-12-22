param ($xmlFileName='.\TestData\basicXml.xml', $structureFileName='.\TestData\basicXmlStructure.csv')

if ($xmlFileName -eq $null) {
    $xmlFileName = read-host -Prompt "Please enter an xmlFileName" 
}   

[xml]$XmlDocument = Get-Content -Path $xmlFileName
$root=$XmlDocument.DocumentElement
[System.Collections.ArrayList]$outPutFileContent= @()

function fillTxt {

    param (
        $struct, $outPutFileContent
    )

    if ($xmlNode.ChildNodes.Count -lt 1){
        #$outPutFileContent.Add([string]$level + ";" + [string]$xmlNode.Name) 
    }
    else {
        $lineNb=$outPutFileContent.Add([string]$level + "," + [string]$xmlNode.Name)
        for ($i=0; $i -lt $xmlNode.ChildNodes.Count; $i=$i+1){
            $nextLevel=$level+1
            $outPut=fillTxt $xmlNode.ChildNodes[$i]  $nextLevel  $outPutFileContent 
            Write-OutPut $outPut
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
            #$struct[$childNode.Name].Add($childStruct)
        }
        else {
            $struct.Add($childNode.Name, $childStruct)
        }
        
    }
}

$struct = @{}
fillStruct $root $struct
Write-Output $struct
foreach($key in $struct.keys)
{
    Write-Output $struct[$key]
}
Set-Content -Path  $structureFileName -Value $null
#$outPutFileContent | foreach { Add-Content -Path  $structureFileName -Value $_ }