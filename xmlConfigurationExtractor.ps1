param ($xmlFileName='.\TestData\basicXml.xml', $structureFileName='.\TestData\basicXmlStructure.csv')

if ($xmlFileName -eq $null) {
    $xmlFileName = read-host -Prompt "Please enter an xmlFileName" 
}   

[xml]$XmlDocument = Get-Content -Path $xmlFileName
$root=$XmlDocument.DocumentElement
$dictStruct=@{}
[System.Collections.ArrayList]$outPutFileContent= @()
$dictStruct["test"]=@{Name="value"}

#function to complete
function fillTxt {

    param (
        $xmlNode, $outPutFileContent,  $level=1 ,$htable=@{}, $currentHtableList=@{}
    )

    if ($xmlNode.ChildNodes.Count -lt 1){
        #$outPutFileContent.Add([string]$level + ";" + [string]$xmlNode.Name) 
        
    }
    else {
        [string]$line=[string]$level + ";" + [string]$xmlNode.Name
        $lineNb=$outPutFileContent.Add($line)
        for ($i=0; $i -lt $xmlNode.ChildNodes.Count; $i=$i+1){
            $nextLevel=$level+1
            $outPut=fillTxt $xmlNode.ChildNodes[$i] $outPutFileContent $nextLevel
            Write-OutPut $outPut
        }
    }
}


#Unfinished function
function getStruct {
    param (
        $outPutFileContent, [int]$lineNb=$outPutFileContent.Count-1, [System.Collections.ArrayList]$struct=@()
    )
    $currentLine=$outPutFileContent.Item($lineNb)
    $currentLevel=getLevel $currentLine
    for ($i=$lineNb-1; $i -gt 0; $i=$i-1){
        $potentialSubLevel=getLevel $outPutFileContent.Item($i)
        if ($potentialSubLevel -eq $currentLevel-1)
        {   
            $subLevelElement=getName $outPutFileContent.Item($i)
            $struct.Add($outPutFileContent.Item($i))
            Write-Output getStruct($outPutFileContent, $i+1, $struct)
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

fillTxt $root $outPutFileContent

$lineNb=$outPutFileContent.Count-1
Write-Output $lineNb

Set-Content -Path  $structureFileName -Value $null
$outPutFileContent | foreach { Add-Content -Path  $structureFileName -Value $_ }