$Source = "https://github.com/hemisphera/DotNetBuilder/archive/refs/tags/v0.0.1.zip"

$ProjectName = ($Source -split "/")[4]
$TempFolder = "$env:TEMP\$([Guid]::NewGuid())"
$UnpackedFolder = "$TempFolder\_unpacked"
$TempFile = "$TempFolder\$ProjectName.zip"
if (Test-Path $TempFolder) { Remove-Item $TempFolder -Recurse -Force }
New-Item -ItemType Directory -Path $TempFolder | Out-Null

Invoke-WebRequest -Method Get -Uri $Source -OutFile $TempFile
Expand-Archive -Path $TempFile -DestinationPath $UnpackedFolder
$ModuleFile = Get-ChildItem $UnpackedFolder -Recurse -Filter "*.psd1" | Select-Object -First 1

$ModuleFolder = "$TempFolder\$($ModuleFile.BaseName)"
New-Item -ItemType Directory -Path $ModuleFolder | Out-Null
Get-ChildItem $ModuleFile.Directory.FullName | Copy-Item -Destination $ModuleFolder -Recurse -Force

Remove-Item $UnpackedFolder -Recurse -Force
Remove-Item $TempFile

Write-Output $ModuleFolder