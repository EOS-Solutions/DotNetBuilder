param(
    [Parameter(Mandatory = $false)]
    [String] $Folder = $pwd,
    [Parameter(Mandatory = $false)]
    [String] $Configuration
)
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\DotNetBuilder.psd1" -DisableNameChecking

. "$PSScriptRoot\dotNetCustomScripts.ps1" -Folder $Folder -Hook BeforePack

$Settings = Get-DotNetBuildSettings -Folder $Folder

$callArgs = @{
    "Folder"       = $Folder
    "OutputFolder" = $Settings.OutputFolder
}
if ($env:BUILD_VERSION) {
    $callArgs += @{ 
        "BuildVersion" = $env:BUILD_VERSION
    }
}
if ($Configuration) {
    $callArgs += @{ 
        "Configuration" = $Configuration
    }
}
Invoke-DotNetPack @callArgs

. "$PSScriptRoot\dotNetCustomScripts.ps1" -Folder $Folder -Hook AfterPack