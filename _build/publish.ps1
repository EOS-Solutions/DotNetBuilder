param(
    [Parameter(Mandatory = $true)]
    [string]$ApiKey
)

$ModuleRoot = Resolve-Path "$PSScriptRoot\.."
Publish-PSResource -ApiKey $ApiKey -Path $ModuleRoot -Verbose