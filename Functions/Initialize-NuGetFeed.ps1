function Initialize-NuGetFeed {

    param(
        [Parameter(Mandatory = $true)]
        [String] $NugetConfigFilename,

        [Parameter(Mandatory = $true)]
        [String] $PackageFeedUrl,
        
        [Parameter(Mandatory = $false)]
        [pscredential] $PackageFeedCredentials,

        [Parameter()]
        [switch] $StorePasswordsInClearText
    )

    if (-not $env:AGENT_ID) { 
        Write-Warning "Not running on agent, skipping NuGet feed initialization"
        return 
    }

    $doc = [System.Xml.XmlDocument]::new()
    $doc.Load($NugetConfigFilename)
    $doc.SelectNodes("configuration/packageSources/add") | Where-Object {
        $Url = $_.Attributes["value"].Value.ToLowerInvariant()
        return $Url.StartsWith($PackageFeedUrl.ToLowerInvariant())
    } | ForEach-Object {
        $FeedName = $_.Attributes["key"].Value
        Write-Host "Removing feed '$FeedName'"
        dotnet nuget remove source $FeedName --configfile "$NugetConfigFilename" | Out-Null
    }

    # we're on devops here, so register a feed with credentials
    $FeedName = "$([Guid]::NewGuid())".Substring(0, 8)
    Write-Host "Registering NuGet credentials on temporary feed '$FeedName'"
    $dotNetArgs = @(
        "nuget", "add", "source", $PackageFeedUrl,
        "--name", $FeedName,
        "--configfile", $NugetConfigFilename
    )
    if ($PackageFeedCredentials) {
        $nc = $PackageFeedCredentials.GetNetworkCredential()
        $dotNetArgs += @(
            "--username", $nc.UserName,
            "--password", $nc.Password
        )
        if ($StorePasswordsInClearText) {
            $dotNetArgs += @( "--store-password-in-clear-text" )
        }
    }
    & dotnet @dotNetArgs | Out-Null

    Write-Output $FeedName

}