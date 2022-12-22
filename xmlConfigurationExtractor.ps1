param ($xmlFileName='.\TestData\basicXml.xml', $structureFileName='.\TestData\basicXmlStructure.csv')

if ($xmlFileName -eq $null) {
    $xmlFileName = read-host -Prompt "Please enter an xmlFileName" 
}   

[xml]$XmlDocument = Get-Content -Path $xmlFileName
$root=$XmlDocument.DocumentElement
[System.Collections.ArrayList]$outPutFileContent= @()

function fillTxt {

    param (
        $xmlNode, $level, $outPutFileContent
    )

    if ($xmlNode.ChildNodes.Count -lt 1){
        #$outPutFileContent.Add([string]$level + ";" + [string]$xmlNode.Name) 
    }
    else {
        $lineNb=$outPutFileContent.Add([string]$level + ";" + [string]$xmlNode.Name)
        for ($i=0; $i -lt $xmlNode.ChildNodes.Count; $i=$i+1){
            $nextLevel=$level+1
            $outPut=fillTxt $xmlNode.ChildNodes[$i]  $nextLevel  $outPutFileContent 
            Write-OutPut $outPut
        }
    }
}

function getStruct {
    param (
        $outPutFileContent, $lineNb=$outPutFileContent.Count-1, [System.Collections.ArrayList]$struct=@()
    )
    $currentLine=$outPutFileContent[$lineNb]
    $currentLevel=getLevel $currentLine
    for ([int]$i=$lineNb; $i -lt 1 ; $i--){
        if ($i == $currentLevel-1)
        {   
            $struct.Add($outPutFileContent[$lineNb])
            Write-Output getStruct($outPutFileContent, $lineNb, $struct)
            break
        }
    }
}

function getName {
    param (
        $line
    )
    $tmp = $line -match '^\d*;(.*);?'
    Write-Output $Matches.1
}

function getLevel {
    param (
        $line
    )
    $tmp = $line -match '(^\d*);'
    if ($Matches.1 -ne $null){
        $level=[int]$Matches.1
        Write-Output $level
    }
    else {
        Write-Output 0
    }
}

fillTxt $root 1 $outPutFileContent
$tmp=getStruct $outPutFileContent 
Write-Output $tmp

Set-Content -Path  $structureFileName -Value $null
$outPutFileContent | foreach { Add-Content -Path  $structureFileName -Value $_ }