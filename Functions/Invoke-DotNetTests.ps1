function Invoke-DotNetTests {

    [CmdletBinding(DefaultParameterSetName = 'FolderName')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "SolutionFilename")]
        [String] $SolutionFilename,
        [Parameter(Mandatory = $false, ParameterSetName = "FolderName")]
        [String] $Folder,
        [Parameter(Mandatory = $true, ParameterSetName = "ProjectFilename")]
        [String] $ProjectFilename,
        [Parameter(Mandatory = $false)]
        [String] $Configuration = "Release",
        [Parameter(Mandatory = $false)]
        [String] $ResultsFilePath,
        [Parameter(Mandatory = $false)]
        [String] $Filter
    )

    $spacer = "".PadRight(80, "#")
    if ($PSCmdlet.ParameterSetName -eq "Folder") {
        if (-not $Folder) { $Folder = $pwd }
        $Folder = Resolve-Path -Path $Folder
        $SolutionFilename = Get-ChildItem $Folder -Filter *.sln | Select-Object -First 1 -ExpandProperty FullName
        $TestSourceFilename = $SolutionFilename
    }
    if ($PSCmdlet.ParameterSetName -eq "SolutionFilename") {
        $SolutionFilename = Resolve-Path -Path $ProjectFilename
        $Folder = [IO.Path]::GetDirectoryName($SolutionFilename)
        $TestSourceFilename = $SolutionFilename
    }
    if ($PSCmdlet.ParameterSetName -eq "ProjectFilename") {
        $ProjectFilename = Resolve-Path -Path $ProjectFilename
        $Folder = [IO.Path]::GetDirectoryName($ProjectFilename)
        $TestSourceFilename = $ProjectFilename
    }

    if (-not $ResultsFilePath) {
        $ResultsFilePath = "$Folder\test-results-{framework}.xml"
    }

    Write-Host "$spacer"
    Write-Host "Running tests for '$TestSourceFilename'"
    Write-Host "$spacer"
    $runArgs = @(
        "test"
        "$TestSourceFilename"
        "-c", $Configuration
        "--logger", "xunit;LogFilePath=$ResultsFilePath"
        "--no-restore"
        "--no-build"
    )
    if ($Filter) {
        $runArgs += @("--filter", $Filter)
    }
    & dotnet @runArgs

}

Export-ModuleMember 'Invoke-DotNetTests'