param(
    [Parameter(Mandatory = $false)]
    [String] $Folder = $pwd,
    [Parameter(Mandatory = $false)]
    [String] $Configuration,
    [Parameter(Mandatory = $false)]
    [String] $BuildVersion
)
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\DotNetBuilder.psd1" -DisableNameChecking

. "$PSScriptRoot\dotNetCustomScripts.ps1" -Folder $Folder -Hook BeforePublish

$Settings = Get-DotNetBuildSettings -Folder $Folder
$callArgs = @{
    "Folder"       = $Folder
    "OutputFolder" = $Settings.OutputFolder
    "WithRestore"  = ("$($Settings.RestoreOnPublish)" -ieq [bool]::TrueString)
    "WithBuild"    = ("$($Settings.BuildOnPublish)" -ieq [bool]::TrueString)
}
if ($Configuration) {
    $callArgs += @{ 
        "Configuration" = $Configuration
    }
}
if (-not $BuildVersion) { $BuildVersion = $env:BUILD_VERSION }
if ($BuildVersion) {
    $callArgs += @{ 
        "BuildVersion" = $BuildVersion
    }
}

Invoke-DotNetPublish @callArgs

. "$PSScriptRoot\dotNetCustomScripts.ps1" -Folder $Folder -Hook AfterPublish