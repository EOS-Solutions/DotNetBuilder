function Get-DotNetBuildSettings {
    
    param (
        [Parameter(Mandatory = $false)]
        [String] $Folder
    )

    if (-not $Folder) { $Folder = $pwd }

    $OutputFolder = $env:BUILD_ArtifactStagingDirectory
    if (-not $OutputFolder) {
        $OutputFolder = "$Folder\_artifacts"
    }

    $DefaultBuildSettings = @{

        OutputFolder = $OutputFolder

    }

    $SettingsFile = [IO.Path]::Combine($Folder, "buildconfig.json")
    if ([IO.File]::Exists($SettingsFile)) {
        $Settings = ConvertFrom-Json (Get-Content $SettingsFile -Encoding UTF8 -Raw)
        foreach ($prop in $Settings.psobject.Properties) {
            $DefaultBuildSettings.Add($prop.Name, $prop.Value)
        }
    }

    Write-Output $DefaultBuildSettings
    
}

Export-ModuleMember 'Get-DotNetBuildSettings'