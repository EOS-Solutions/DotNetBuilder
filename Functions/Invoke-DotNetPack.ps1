function Invoke-DotNetPack {

    [CmdletBinding(DefaultParameterSetName = 'FolderName')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "SolutionFilename")]
        [String] $SolutionFilename,
        [Parameter(Mandatory = $false, ParameterSetName = "FolderName")]
        [String] $Folder,
        [Parameter(Mandatory = $true, ParameterSetName = "ProjectFilename")]
        [String] $ProjectFilePath,
        [Parameter(Mandatory = $false)]
        [String] $Configuration = "Release",
        [Parameter(Mandatory = $true)]
        [String] $OutputFolder,
        [Parameter(Mandatory = $false)]
        [string] $BuildVersion
    )

    if (-not $ProjectFilePath) {
        if (-not $SolutionFilename) {
            if (-not $Folder) { $Folder = $pwd }
            $Folder = Resolve-Path $Folder
            $SolutionFilename = Get-ChildItem $Folder -Filter *.sln | Select-Object -First 1 -ExpandProperty FullName
        }
        else {
            $Folder = [IO.Path]::GetDirectoryName($SolutionFilename)
        }

        $Config = Get-DotNetBuildSettings -Folder $Folder
        $Packages = $Config["ProjectsToPack"]
        if ($Packages) {
            foreach ($item in $Packages) {
                $ProjectPathToPublish = [IO.Path]::Combine($Folder, $item)
                $PublishOutputFolder = [IO.Path]::GetFileNameWithoutExtension($ProjectPathToPublish)
                $PublishOutputFolder = [IO.Path]::Combine($OutputFolder, $PublishOutputFolder)
                Invoke-DotNetPack -ProjectFilePath $ProjectPathToPublish -Configuration $Configuration -OutputFolder $PublishOutputFolder -BuildVersion $BuildVersion
            }
        }
    }
    else {

        Write-Host "Output folder is '$OutputFolder'"
        if (Test-Path $OutputFolder) { Remove-Item $OutputFolder -Force -Recurse }

        $packArgs = @(
            "pack"
            $ProjectFilePath
            "-c", $Configuration
            "-o", $OutputFolder
            "--no-restore"
            "--no-build"
        )
        if ($BuildVersion) {
            $VersionParts = $BuildVersion.Split('.')
            $SemBuildVersion = "$($VersionParts[0]).$($VersionParts[1]).$($VersionParts[2])"
            Write-Host "Using explicit package version: $SemBuildVersion"
            $packArgs += @(
                "/p:PackageVersion=`"$SemBuildVersion`""
            )
        }

        Write-Host "Packing '$ProjectFilePath'"
        & dotnet @packArgs
        if ($LASTEXITCODE -ne 0) { throw "Failed" }
    
    }

}

Export-ModuleMember 'Invoke-DotNetPack'