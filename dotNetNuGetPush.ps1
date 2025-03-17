$ErrorActionPreference = "Stop"

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

$NuGetPackages = Get-ChildItem $ArtifactRoot -Filter *.nupkg -Recurse
if (-not $NuGetPackages) {
    Write-Host "No NuGet packages found in '$ArtifactRoot', exiting ..."
    return
}

Import-Module "$PSScriptRoot\DotNetBuilder.psd1" -DisableNameChecking

foreach ($NuGetPackage in $NuGetPackages) {
    
    Publish-NuGetPackage `
        -PackageFilePath $NuGetPackage.FullName `
        -SourceUrl "$(Get-InputVariable PROGET_BASEURL -Require)/nuget/Default" `
        -ApiKey (Get-InputVariable PROGET_API_KEY -Require)

}