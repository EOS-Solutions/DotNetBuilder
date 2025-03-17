param(
    [Parameter(Mandatory = $false)]
    [String] $Folder = $pwd,
    [Parameter(Mandatory = $true)]
    [String] $Hook
)

Write-Host "Running hook '$Hook'"
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\DotNetBuilder.psd1" -DisableNameChecking

$Settings = Get-DotNetBuildSettings -Folder $Folder
$KeyName = "$($Hook)Scripts"
$Scripts = $Settings[$KeyName]
if ($Scripts) {
    foreach ($Script in $Scripts) {
        $FullScriptName = "$Folder\$Script"
        if ([IO.File]::Exists($FullScriptName)) {
            Write-Host "Running script '$FullScriptName'"
            . $FullScriptName
        }
        else {
            throw "The specified script '$FullScriptName' does not exist."
        }
    }
}