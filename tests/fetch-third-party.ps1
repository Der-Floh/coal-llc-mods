<#
.SYNOPSIS
Downloads the third-party mods listed in src/ThirdParty/ThirdParty-Mods.csv as zips Godot Mod Loader can load.

.DESCRIPTION
Each row (Name, Author, Url) becomes src/ThirdParty/<Author>/<Name>.zip, which the integration tests load in the sessions that ask for that mod. Where it came from (a release tag or a branch) is written next to it as <Name>.zip.source.

- github.com/<owner>/<repo>: the latest release's .zip asset, the file players install. Without a release, the default branch is packed when it has manifest.json at its root.
- github.com/<owner>/<repo>/tree/<ref>/<path>: that folder at <ref>, packed as a mod.
- Any other host: put the zip there yourself.

Existing zips are kept unless -Update is given. Nothing else in src/ThirdParty is touched; the mods there are references and are never edited.

.PARAMETER Name
Only fetch the rows with these names.

.PARAMETER Update
Download again even when the zip already exists.

.EXAMPLE
./tests/fetch-third-party.ps1
#>
[CmdletBinding()]
param(
    [string[]]$Name,
    [switch]$Update
)

. (Join-Path $PSScriptRoot '..\.vscode\build\common.ps1')

$ThirdPartyDirectory = Join-Path $DefaultSourceDirectory $ThirdPartyDirectoryName
$ModListFile = Join-Path $ThirdPartyDirectory 'ThirdParty-Mods.csv'
$SourceSuffix = '.source'
$GitHubUrlPattern = '^https://github\.com/(?<owner>[^/]+)/(?<repo>[^/]+?)(?:\.git)?(?:/tree/(?<ref>[^/]+)/(?<path>.+?))?/?$'
$ApiRoot = 'https://api.github.com/repos'
$ArchiveRoot = 'https://codeload.github.com'
$RequestHeaders = @{ 'User-Agent' = 'coal-llc-mods-tests'; Accept = 'application/vnd.github+json' }
if ($env:GITHUB_TOKEN) { $RequestHeaders.Authorization = "Bearer $env:GITHUB_TOKEN" }

function Get-ThirdPartyZipPath {
    param([Parameter(Mandatory)][psobject]$Row)

    Join-Path (Join-Path $ThirdPartyDirectory $Row.Author) "$($Row.Name).zip"
}

function New-TemporaryDirectory {
    New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString('N')))
}

function Save-Download {
    param([Parameter(Mandatory)][string]$Url, [Parameter(Mandatory)][string]$Path)

    Invoke-WebRequest -Uri $Url -Headers $RequestHeaders -OutFile $Path -UseBasicParsing
}

function Get-LatestReleaseZip {
    param([Parameter(Mandatory)][string]$Owner, [Parameter(Mandatory)][string]$Repo)

    try {
        $release = Invoke-RestMethod -Uri "$ApiRoot/$Owner/$Repo/releases/latest" -Headers $RequestHeaders
    }
    catch {
        if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 404) { return $null }
        throw
    }
    $asset = @($release.assets | Where-Object { $_.name -like '*.zip' }) | Select-Object -First 1
    if (-not $asset) { return $null }
    [pscustomobject]@{ Url = $asset.browser_download_url; Source = "release $($release.tag_name)" }
}

function Get-DefaultBranch {
    param([Parameter(Mandatory)][string]$Owner, [Parameter(Mandatory)][string]$Repo)

    (Invoke-RestMethod -Uri "$ApiRoot/$Owner/$Repo" -Headers $RequestHeaders).default_branch
}

function Get-ModId {
    param([Parameter(Mandatory)][string]$ModDirectory)

    $manifest = Get-Content -LiteralPath (Join-Path $ModDirectory $ManifestFileName) -Raw -Encoding UTF8 | ConvertFrom-Json
    "$($manifest.namespace)-$($manifest.name)"
}

# Packs one folder of a GitHub source archive; the zip's folder is named after the mod id, as GML requires.
function New-ZipFromSource {
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Ref,
        [string]$Path,
        [Parameter(Mandatory)][string]$ZipPath
    )

    $workDirectory = New-TemporaryDirectory
    try {
        $archive = Join-Path $workDirectory.FullName 'source.zip'
        Save-Download -Url "$ArchiveRoot/$Owner/$Repo/zip/$Ref" -Path $archive
        $extracted = Join-Path $workDirectory.FullName 'source'
        Expand-Archive -LiteralPath $archive -DestinationPath $extracted
        $root = @(Get-ChildItem -LiteralPath $extracted -Directory)[0].FullName
        $modDirectory = if ($Path) { Join-Path $root $Path } else { $root }
        if (-not (Test-Path -LiteralPath (Join-Path $modDirectory $ManifestFileName) -PathType Leaf)) {
            throw "No $ManifestFileName in $Owner/$Repo at '$Ref' $(if ($Path) { "under $Path" } else { 'in its root' })."
        }
        New-ModZip -ModDirectory (Get-Item -LiteralPath $modDirectory) -ZipPath $ZipPath -ModFolderName (Get-ModId $modDirectory)
    }
    finally {
        Remove-Item -LiteralPath $workDirectory.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Save-ThirdPartyMod {
    param([Parameter(Mandatory)][psobject]$Row, [Parameter(Mandatory)][string]$ZipPath)

    if ($Row.Url -notmatch $GitHubUrlPattern) {
        Write-Warning "$($Row.Name): $($Row.Url) is not a GitHub URL; put the mod's zip at $ZipPath yourself."
        return
    }
    $owner = $Matches['owner']
    $repo = $Matches['repo']
    $ref = $Matches['ref']
    $path = $Matches['path']
    New-Item -ItemType Directory -Path (Split-Path $ZipPath -Parent) -Force | Out-Null
    $partial = "$ZipPath.partial"
    Remove-Item -LiteralPath $partial -ErrorAction SilentlyContinue

    if ($ref) {
        New-ZipFromSource -Owner $owner -Repo $repo -Ref $ref -Path $path -ZipPath $partial
        $source = "tree $ref/$path"
    }
    elseif ($release = Get-LatestReleaseZip -Owner $owner -Repo $repo) {
        Save-Download -Url $release.Url -Path $partial
        $source = $release.Source
    }
    else {
        $branch = Get-DefaultBranch -Owner $owner -Repo $repo
        New-ZipFromSource -Owner $owner -Repo $repo -Ref $branch -ZipPath $partial
        $source = "branch $branch"
    }
    Move-Item -LiteralPath $partial -Destination $ZipPath -Force
    Set-Content -LiteralPath "$ZipPath$SourceSuffix" -Value $source -Encoding UTF8
    Write-Host "Fetched: $($Row.Name) ($source) -> $ZipPath"
}

if (-not (Test-Path -LiteralPath $ModListFile -PathType Leaf)) { throw "No third-party mod list at $ModListFile." }

foreach ($row in Import-Csv -LiteralPath $ModListFile) {
    if ($Name -and $Name -notcontains $row.Name) { continue }
    $zipPath = Get-ThirdPartyZipPath $row
    if ((Test-Path -LiteralPath $zipPath -PathType Leaf) -and -not $Update) {
        Write-Host "Kept: $($row.Name) ($(Get-Content -LiteralPath "$zipPath$SourceSuffix" -ErrorAction SilentlyContinue))"
        continue
    }
    Save-ThirdPartyMod -Row $row -ZipPath $zipPath
}
