function Publish-NuGetPackage {
    
    param (
        [Parameter(Mandatory = $true)]
        [String] $PackageFilePath,
        [Parameter(Mandatory = $true)]
        [String] $SourceUrl,
        [Parameter(Mandatory = $true)]
        [String] $ApiKey
    )
 
    Write-Host "Publishing '$PackageFilePath'"

    $nugetPushArgs = @(
        "nuget", "push"
        $PackageFilePath
        "--source", $SourceUrl
        "--api-key", $ApiKey
    )
    & dotnet @nugetPushArgs
    if ($LASTEXITCODE -ne 0) { throw "Failed" }

}

Export-ModuleMember "Publish-NuGetPackage"