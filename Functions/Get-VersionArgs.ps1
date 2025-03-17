function Get-VersionArgs {
    param(
        [Parameter(Mandatory = $true)]
        [String] $Version
    )

    $VersionParts = $BuildVersion.Split(".")
    $ActualBuildVersion = "`"$($VersionParts[0]).$($VersionParts[1]).$($VersionParts[2])`""
    $BuildAssemblyVersion = "`"$($VersionParts[0]).$($VersionParts[1]).0`""
    Write-Host "Using explicit assembly file version: $ActualBuildVersion"
    Write-Host "Using explicit assembly version: $BuildAssemblyVersion"
    Write-Host "Using explicit product version: $BuildAssemblyVersion"
    $buildArgs = @(
        "/p:AssemblyVersion=$BuildAssemblyVersion"
        "/p:AssemblyFileVersion=$ActualBuildVersion"
        "/p:AssemblyInformationalVersion=$ActualBuildVersion"
        "/p:Version=$ActualBuildVersion"
    )
    Write-Output $buildArgs

}