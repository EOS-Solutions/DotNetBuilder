param(
    [Parameter(Mandatory = $false)]
    [String] $Folder = $pwd,
    [Parameter(Mandatory = $false)]
    [String] $Configuration,
    [Parameter(Mandatory = $false)]
    [String] $Filter
)
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\DotNetBuilder.psd1" -DisableNameChecking

$Config = Get-DotNetBuildSettings -Folder $Folder
if ($Config.SkipTests) {
    Write-Host "Skipping tests"
    exit
}

. "$PSScriptRoot\dotNetCustomScripts.ps1" -Folder $Folder -Hook BeforeTests

$callArgs = @{}
if ($Config.ProjectToTest) {
    $callArgs += @{ "ProjectFilename" = $Config.ProjectToTest }
}
else {
    $callArgs += @{ "Folder" = $Folder }
}
if ($Configuration) {
    $callArgs += @{ 
        "Configuration" = $Configuration
    }
}
if ($Filter) {
    $callArgs += @{ 
        "Filter" = $Filter
    }
}

Invoke-DotNetTests @callArgs

. "$PSScriptRoot\dotNetCustomScripts.ps1" -Folder $Folder -Hook AfterTests