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

. "$PSScriptRoot\dotNetCustomScripts.ps1" -Folder $Folder -Hook BeforeBuild

$callArgs = @{
    "Folder"                       = $Folder
    StoreNugetPasswordsInClearText = $true # workaround for temporary .NET issue (https://github.com/dotnet/sdk/issues/23498)
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
Invoke-DotNetBuild @callArgs

. "$PSScriptRoot\dotNetCustomScripts.ps1" -Folder $Folder -Hook AfterBuild