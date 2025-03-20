function Invoke-DotNetBuild {

    [CmdletBinding(DefaultParameterSetName = 'FolderName')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "SolutionFilename")]
        [String] $SolutionFilename,
        [Parameter(Mandatory = $false, ParameterSetName = "FolderName")]
        [String] $Folder,
        [Parameter(Mandatory = $false)]
        [String] $Configuration = "Release",
        [Parameter(Mandatory = $false)]
        [string] $BuildVersion,
        [Parameter(Mandatory = $false)]
        [switch] $StoreNugetPasswordsInClearText
    )

    Write-Verbose $Folder
    $spacer = "".PadRight(80, "#")
    if (-not $SolutionFilename) {
        if (-not $Folder) { $Folder = $pwd }
        $Folder = Resolve-Path $Folder
        Write-Verbose $Folder
        $SolutionFilename = Get-ChildItem $Folder -Filter *.sln | Select-Object -First 1 -ExpandProperty FullName
        Write-Verbose $SolutionFilename
    }
    else {
        $Folder = [IO.Path]::GetDirectoryName($SolutionFilename)
    }


    Write-Host "$spacer"
    Write-Host "Restoring solution '$SolutionFilename'"
    Write-Host "$spacer"
    $restoreArgs = @(
        "restore"
        $SolutionFilename
    )

    $NugetConfigFile = [System.IO.FileInfo]::new([IO.Path]::Combine($Folder, "nuget.config"))
    if ($NugetConfigFile.Exists) {
        $restoreArgs += @(
            "--configfile", $NugetConfigFile.FullName
        )
    }

    if (-not $env:AGENT_ID) { 
        $restoreArgs += @( "--interactive" )
    }
    & dotnet @restoreArgs
    if ($LASTEXITCODE -ne 0) { throw "Failed" }

    Write-Host "$spacer"
    Write-Host "Building solution '$SolutionFilename'"
    Write-Host "$spacer"
    
    $buildArgs = @(
        "build"
        $SolutionFilename
        "-c", $Configuration
    )
    if ($BuildVersion) { $buildArgs += (Get-VersionArgs $BuildVersion) }
    Write-Host $buildArgs
    & dotnet @buildArgs
    if ($LASTEXITCODE -ne 0) { throw "Failed" }

}

Export-ModuleMember 'Invoke-DotNetBuild'