<#
.SYNOPSIS
    Get the credentials searching in list of creds registered first with the NugetAuthenticate task
#>
function Get-NugetCredentials {

    param(
        [Parameter(Mandatory = $false)]
        [Uri] $Uri,
        
        [Parameter(Mandatory = $false)]
        [Uri] $User

    )

    try {
        write-verbose "retrieving credentials from registered NUGET authentication credentials"
        $Credentials = $null

        $endpoints = $env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS
    
        if (!$endpoints) {
            write-verbose "no registered endpoints found!"
            return 
        }
    
        $allEndpointCredentials = ($endpoints | ConvertFrom-Json).endpointCredentials
        Write-Verbose "$($allEndpointCredentials.Count) endpoint(s) found"

        if ($Uri) {
            write-verbose "using passed uri '$Uri'" 
            $Credentials = $allEndpointCredentials | Where-Object {
                $Uri.ToString().ToLowerInvariant().StartsWith($_.endpoint.ToLowerInvariant())
            } | Select-Object -First 1
        }
        elseif ($allEndpointCredentials.Count -eq 1) {
            write-verbose "using credentials of single endpoint"
            $Credentials = $allEndpointCredentials[0]
        }

        if ($Credentials) {
            $SecurePassword = ConvertTo-SecureString -AsPlainText -Force $Credentials.password 
            $UserName = $Credentials.username
            if (-not $UserName) { $UserName = $User }
            if (-not $UserName) { $UserName = "pat" }
            $Credentials = New-Object PSCredential -ArgumentList ($Username, $SecurePassword)
        }

        Write-Verbose "Gotten credentials for user '$($Credentials.UserName)'"
        Write-Verbose "Password length is $($Credentials.GetNetworkCredential().Password.Length)"
 
    }
    catch {
        write-host "Failed to get credentials:`n$($_.Exception)"
        $Credentials = $null
    }
    finally {
        Write-Output $Credentials
    }

}
Export-ModuleMember "Get-CredsFromRegEndpoints"