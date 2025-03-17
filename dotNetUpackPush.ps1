param(
    [Parameter(Mandatory = $false)]
    [String] $Feed = "tools"
)

$ErrorActionPreference = "Stop"

$ModuleRoot = Resolve-Path "$PSScriptRoot\..\.."
Import-Module "$ModuleRoot\..\Common\Common.psm1" -DisableNameChecking
Import-HspPsUpack

$ArtifactRoot = $env:PIPELINE_WORKSPACE
if (-not $ArtifactRoot) {
    Write-Warning "The variable 'PIPELINE_WORKSPACE' is not defined. Exiting ..."
    return
}
$ArtifactRoot = [IO.Path]::Combine($ArtifactRoot, 'output')
if (-not [IO.Directory]::Exists($ArtifactRoot)) {
    Write-Warning "The directory '$ArtifactRoot' does not exist. Exiting ..."
    return
}

$BuildVersion = Get-InputVariable "BUILD_VERSION" -Require
$BuildVersion = [Version]::Parse($BuildVersion)
$BuildVersion = "$($BuildVersion.Major).$($BuildVersion.Minor).$($BuildVersion.Build)"
Write-Host "Using '$BuildVersion' as build version."

$ProGet_BaseUrl = Get-InputVariable "PROGET_BASEURL" -Require
$ProGet_ApiKey = Get-InputVariable "PROGET_API_KEY" -Require

$ManifestPaths = Get-ChildItem $ArtifactRoot -Filter "upack.json" -Recurse | Select-Object -ExpandProperty FullName
if (-not $ManifestPaths) {
    Write-Host "No UPack Manifests found in '$ArtifactRoot', exiting ..."
    return
}

foreach ($ManifestPath in $ManifestPaths) {

    $PackageFolder = [IO.Path]::GetDirectoryName($ManifestPath)
    Write-Host "Creating UPack package from folder '$PackageFolder'"
    Write-Host "Using Proget Feed: '$Feed'"
    Write-Host "$ProGet_BaseUrl/upack/$Feed"
    $Manifest = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
    Remove-Item $ManifestPath
    Hsp.Ps.Upack\Publish-UPackPackage `
        -FolderPath $PackageFolder `
        -Name $Manifest.Name `
        -Title $Manifest.Title `
        -IconUrl $Manifest.IconUrl `
        -Version $BuildVersion `
        -FeedUri "$ProGet_BaseUrl/upack/$Feed" `
        -ApiKey "$ProGet_ApiKey"

}