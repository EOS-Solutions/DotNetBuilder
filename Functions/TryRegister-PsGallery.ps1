<#
.SYNOPSIS
Tries to register a PS gallery or returns the name of the PS gallery, if the URL is already registered.
#>
function TryRegister-PSGallery {

    param(
        # The URI to the NuGet feed to be registered as a PS gallery
        [Parameter(Mandatory = $true)] [String] $Uri,
        # The credentials to use when registering the PS gallery. This is optional and depends on the PS gallery to be registered.
        [Parameter(Mandatory = $false)] [pscredential] $Credentials,
        # The name of the PS gallery to be registered. This is mandatory if you use 'NonTemporary'. Otherwise a random name will be generated.
        [Parameter(Mandatory = $false)] [string] $Name,
        # Specifies if the PS gallery should be registered persistently. If this is true, 'Name' is mandatory. Otherwise a random name will be generated.
        [Parameter(Mandatory = $false)] [switch] $NonTemporary
    )

    $ResultObject = @{
        FeedName    = ""
        IsTemporary = $false
    }

    $ExistingItem = Get-PSRepository | Where-Object { $_.PublishLocation -ieq $Uri }
    if ($ExistingItem) {
        $ResultObject["FeedName"] = $ExistingItem.Name
        $ResultObject["IsTemporary"] = $false
    }
    else {
        if (-not $Name) {
            if ($NonTemporary) { throw "You must specify 'Name' if you use the switch 'NonTemporary'" }
            $Name = "$([Guid]::NewGuid())".Replace("-", "")
        }
        $ResultObject["FeedName"] = $Name
        $ResultObject["IsTemporary"] = (-not $NonTemporary)

        $registerArgs = @{
            Name            = $ResultObject.FeedName
            SourceLocation  = $Uri
            PublishLocation = $uri 
        }
        if ($Credentials) {
            $registerArgs += @{
                Credentials = $Credentials
            }
        }
        Register-PSRepository @registerArgs
    }

    Write-Output $ResultObject

}

Export-ModuleMember TryRegister-PSGallery