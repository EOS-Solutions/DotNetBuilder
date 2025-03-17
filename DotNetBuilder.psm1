Get-ChildItem "$PSScriptRoot\Functions" -Filter *.ps1 -Recurse | ForEach-Object { . $_.FullName }

Set-Variable "DotNetBuilder_Root" -Value $PSScriptRoot -Scope Global -Force
Export-ModuleMember -Variable "DotNetBuilder_Root"