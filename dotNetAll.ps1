param(
    [Parameter(Mandatory = $false)]
    [String] $Folder = $pwd,
    [Parameter(Mandatory = $false)]
    [String] $Configuration = "Debug",
    [Parameter(Mandatory = $false)]
    [String] $TestFilter
)

. $DotNetBuilder_Root\Scripts\dotNet\dotNetBuild.ps1 -Configuration $Configuration -Folder $Folder
. $DotNetBuilder_Root\Scripts\dotNet\dotNetPublish.ps1 -Configuration $Configuration -Folder $Folder
$TestArgs = @{
    Folder        = $Folder
    Configuration = $Configuration
}
if ($TestFilter) {
    $TestArgs += @{ "Filter" = $TestFilter }
}
. $DotNetBuilder_Root\Scripts\dotNet\dotNetTest.ps1 @TestArgs