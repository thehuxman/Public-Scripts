$pattern = '[^0-9]'
$destdir = "$env:USERPROFILE\OneDrive\Personal Documents\Background Images"
$date = Get-Date -Format "dd MMM yyyy"
$WorkingDir = "$env:USERPROFILE\Pictures\Spotlight\$date"
$ErrorActionPreference = "SilentlyContinue"


Function Get-FileMetaData 
{ 
  <# 
   .Synopsis 
    This function gets file metadata and returns it as a custom PS Object  
   .Description 
    This function gets file metadata using the Shell.Application object and 
    returns a custom PSObject object that can be sorted, filtered or otherwise 
    manipulated. 
   .Example 
    Get-FileMetaData -folder "e:\music" 
    Gets file metadata for all files in the e:\music directory 
   .Example 
    Get-FileMetaData -folder (gci e:\music -Recurse -Directory).FullName 
    This example uses the Get-ChildItem cmdlet to do a recursive lookup of  
    all directories in the e:\music folder and then it goes through and gets 
    all of the file metada for all the files in the directories and in the  
    subdirectories.   
   .Example 
    Get-FileMetaData -folder "c:\fso","E:\music\Big Boi" 
    Gets file metadata from files in both the c:\fso directory and the 
    e:\music\big boi directory. 
   .Example 
    $meta = Get-FileMetaData -folder "E:\music" 
    This example gets file metadata from all files in the root of the 
    e:\music directory and stores the returned custom objects in a $meta  
    variable for later processing and manipulation. 
   .Parameter Folder 
    The folder that is parsed for files  
   .Notes 
    NAME:  Get-FileMetaData 
    AUTHOR: ed wilson, msft 
    LASTEDIT: 01/24/2014 14:08:24 
    KEYWORDS: Storage, Files, Metadata 
    HSG: HSG-2-5-14 
   .Link 
     Http://www.ScriptingGuys.com 
 #Requires -Version 2.0 
 #> 
 Param([string[]]$folder) 
 foreach($sFolder in $folder) 
  { 
   $a = 0 
   $objShell = New-Object -ComObject Shell.Application 
   $objFolder = $objShell.namespace($sFolder) 
 
   foreach ($File in $objFolder.items()) 
    {  
     $FileMetaData = New-Object PSOBJECT 
      for ($a ; $a  -le 266; $a++) 
       {  
         if($objFolder.getDetailsOf($File, $a)) 
           { 
             $hash += @{$($objFolder.getDetailsOf($objFolder.items, $a))  = 
                   $($objFolder.getDetailsOf($File, $a)) } 
            $FileMetaData | Add-Member $hash 
            $hash.clear()  
           } #end if 
       } #end for  
     $a=0 
     $FileMetaData 
    } #end foreach $file 
  } #end foreach $sfolder 
} #end Get-FileMetaData

Function Get-FileHashes {
$DestArray = @()
$DestArray = (Get-ChildItem -Path $destdir -Recurse | Get-FileHash).Hash | Out-Null
$SourceArray = @()
$SourceArray = (Get-ChildItem -Path $WorkingDir -Recurse | Get-FileHash).Hash | Out-Null
}

#region CopyStart


new-item $WorkingDir -ItemType Directory -Force

Copy-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\*" -Destination $WorkingDir -Recurse 

Get-ChildItem -Path $WorkingDir -Recurse | ?{!$_.PsIsContainer} | ren -new {$_.name + ".jpg"} 

#endregion 

#region HashandCopy
$Pics = Get-FileMetaData -folder $WorkingDir 
foreach ($pic in $pics) {

        try {
            $PicWidth = ($Pic.Dimensions.Split(" ")[0] -replace $pattern, " ").trim()
            }
        Catch {
            Remove-Item ($WorkingDir + "\" + $Pic.Name) -Force 
               }

$PicWidthInt = [int]$PicWidth

    if ($PicWidthInt -lt 1920) {
          Remove-Item $Pic.Path -Force
        }
    else {
          Get-FileHashes
          foreach ($SourceHash in $SourceArray) {
            if ($DestArray -notcontains $SourceHash) {
                Copy-Item -Path ($WorkingDir + "\" + $Pic.Name) -Destination $destdir  -Recurse | Out-Null ##Update to your location
            }
          }

    }

}
#endregion 


Remove-Item -Path $WorkingDir -Recurse -Force
