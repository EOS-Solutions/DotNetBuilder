function Invoke-DotNetPublish {

    [CmdletBinding(DefaultParameterSetName = 'FolderName')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "SolutionFilename")]
        [String] $SolutionFilename,
        [Parameter(Mandatory = $false, ParameterSetName = "FolderName")]
        [String] $Folder,
        [Parameter(Mandatory = $false)]
        [string] $BuildVersion,
        [Parameter(Mandatory = $true, ParameterSetName = "ProjectFilename")]
        [String] $ProjectFilePath,
        [Parameter(Mandatory = $false)]
        [String] $Configuration = "Release",
        [Parameter(Mandatory = $true)]
        [String] $OutputFolder,
        [Parameter(Mandatory = $false)]
        [switch] $WithRestore,
        [Parameter(Mandatory = $false)]
        [switch] $WithBuild
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
        $Packages = $Config["ProjectsToPublish"]
        if ($Packages) {
            foreach ($item in $Packages) {
                $ProjectPathToPublish = [IO.Path]::Combine($Folder, $item)
                $PublishOutputFolder = [IO.Path]::GetFileNameWithoutExtension($ProjectPathToPublish)
                $PublishOutputFolder = [IO.Path]::Combine($OutputFolder, $PublishOutputFolder)
                Invoke-DotNetPublish -ProjectFilePath $ProjectPathToPublish -BuildVersion $BuildVersion -Configuration $Configuration -OutputFolder $PublishOutputFolder -WithRestore:$WithRestore -WithBuild:$WithBuild
            }
        }
    }
    else {

        Write-Host "Output folder is '$OutputFolder'"
        if (Test-Path $OutputFolder) { Remove-Item $OutputFolder -Force -Recurse }

        [System.Xml.XmlDocument] $projectFile = [Xml.XmlDocument]::new()
        $projectFile.Load($ProjectFilePath)
        $FrameworksNode = $projectFile.SelectSingleNode("Project/PropertyGroup/TargetFramework")
        if (-not $FrameworksNode) {
            $FrameworksNode = $projectFile.SelectSingleNode("Project/PropertyGroup/TargetFrameworks")
        }
        if (-not $FrameworksNode) {
            throw "Unable to detect target frameworks for project file '$ProjectFilePath'"
        }

        $Runtime = $projectFile.SelectSingleNode("Project/PropertyGroup/RuntimeIdentifier").InnerText
        if (-not $Runtime) {
            $Runtime = $projectFile.SelectSingleNode("Project/PropertyGroup/RuntimeIdentifiers").InnerText
        }

        $BaseArgs = @(
            "publish", $ProjectFilePath,
            "-c", $Configuration
        )
        if (-not $WithBuild) { 
            $BaseArgs += @("--no-build")
        }
        if (-not $WithRestore) { 
            $BaseArgs += @("--no-restore")
        }
        if ($Runtime) {
            Write-Host "Found runtime '$Runtime', publishing self-contained."
            $BaseArgs += @(
                "--self-contained", "true"
                "--runtime", $Runtime
            )
        }

        $VersionArgs = @()
        if ($BuildVersion) { $VersionArgs += (Get-VersionArgs $BuildVersion) }
    
        $Frameworks = $FrameworksNode.InnerText.Split(';')
        foreach ($Framework in $Frameworks) {
            $PubArgs = $BaseArgs
            $PubArgs += @(
                "-o", "$OutputFolder\$Framework",
                "--framework", $Framework
            )
            $PubArgs += $VersionArgs
            Write-Host "Publishing '$ProjectFilePath' for framework '$Framework'"
            dotnet @PubArgs
            if ($LASTEXITCODE -ne 0) { throw "Failed" }
        }

    }

}

Export-ModuleMember 'Invoke-DotNetPublish'