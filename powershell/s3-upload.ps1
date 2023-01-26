#AWS S3 Upload Directory Script
Import-Module AWS.Tools.Common
Import-Module AWS.Tools.S3

# Get the BucketName
$BucketName = read-host -prompt 'target bucket name'

#Determine Folder Name Hash
$mystring = $($PWD | Select-Object -ExpandProperty Path | Foreach-Object { $_ -replace '.*\\'})
$mystream = [IO.MemoryStream]::new([byte[]][char[]]$mystring)
$folderHash = Get-FileHash -InputStream $mystream -Algorithm MD5 | Select-Object -ExpandProperty Hash

Write-Host "-----------------------------"
Write-Host " S3 UPLOAD UTIL "
Write-Host "-----------------------------"
Write-Host ""
Write-Host "Folder To Upload: $mystring"
Write-Host "Folder Name Hash: $folderHash"
Write-Host ""
Write-Host "-----------------------------"
Write-Host " Uploading Files"
Write-Host "-----------------------------"
Write-Host ""

# Process Files
try{
    $Items = Get-ChildItem -Path *
    foreach ($Item in $Items){
        $ItemToHash = $Item
        $ItemHash =  $ItemToHash | Get-FileHash -Algorithm MD5 | Select-Object -ExpandProperty Hash
        Write-Host "File: $($Item.Name)  AS  $($ItemHash)$($ItemToHash.Extension)"
        Write-S3Object -BucketName $BucketName -File $Item.Name -Key "$($folderHash)/$($ItemHash)$($ItemToHash.Extension)" -PublicReadOnly -ProfileName acs
    }
}

finally{
    Write-Host ""
    Write-Host "-----------------------------"
    Write-Host " Upload Complete."
    Write-Host "-----------------------------"
    Write-Host ""
}
