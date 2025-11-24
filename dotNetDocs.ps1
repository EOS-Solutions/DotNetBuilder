param(
    [Parameter(Mandatory = $false)]
    [String] $Folder = $pwd,
    [Parameter(Mandatory = $false)]
    [String] $Configuration
)
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\DotNetBuilder.psd1" -DisableNameChecking

$Settings = Get-DotNetBuildSettings -Folder $Folder
$DocFxDocFxConfigurationFile = $Settings.DocFxConfiguration
if (-not $DocFxDocFxConfigurationFile) {
    $DocFxDocFxConfigurationFile = [IO.Path]::Combine($Folder, "docfx\docfx.json")
}

if (-not (Test-Path $DocFxDocFxConfigurationFile)) {
    Write-Host "DocFx configuration file not found. Skipping documentation generation."
    return
}

$DocFxDocFxConfiguration = ConvertFrom-Json (Get-Content -Path $DocFxDocFxConfigurationFile -Raw)

dotnet tool install docfx --global
$callArgs = @(
    "metadata",
    $DocFxDocFxConfigurationFile,
    "--output", $Settings.OutputFolder
)
& docfx.exe @callArgs

$ActualOutput = [IO.Path]::Combine($Settings.OutputFolder, $DocFxDocFxConfiguration.metadata[0].dest)
Write-Host "Actual output folder: $ActualOutput"
Compress-Archive -LiteralPath $ActualOutput -DestinationPath "$($Settings.OutputFolder)\docfx.zip" -Force
Remove-Item $ActualOutput -Recurse -Force