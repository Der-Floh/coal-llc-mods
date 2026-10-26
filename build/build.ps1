<#
.SYNOPSIS
Packs every mod in src/<author>/<mod>/ into a zip for Godot Mod Loader and writes the Nexus Mods descriptions.

.DESCRIPTION
Each zip is named <namespace>-<name>-<version_number>.zip from the mod's manifest.json and holds the mod folder under mods-unpacked/, the layout GML expects. The mod's media/ folder, with the images for its mod page, is left out. It is written to the folder of the mod's author in the output folder, <author>/ like src/<author>/, and zips of other versions of the same mod are removed from there.

After packing, nexus-descriptions.ps1 converts the README of every mod in .github/nexus-mods.json into its Nexus Mods description, written to nexus/ in the output folder.

.PARAMETER SourceDirectory
Folder holding the author folders. Defaults to src/ in the repository root.

.PARAMETER OutputDirectory
Folder the author folders with the zips and the nexus/ folder with the descriptions are written to. Defaults to out/ in the repository root.

.EXAMPLE
./build/build.ps1 -OutputDirectory ./dist
#>
[CmdletBinding()]
param(
    [string]$SourceDirectory,
    [string]$OutputDirectory
)

. (Join-Path $PSScriptRoot 'common.ps1')

if (-not $SourceDirectory) { $SourceDirectory = $DefaultSourceDirectory }
if (-not $OutputDirectory) { $OutputDirectory = $DefaultZipDirectory }

function Get-ManifestValue {
    param(
        [Parameter(Mandatory)][psobject]$Manifest,
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$ManifestPath
    )

    $property = $Manifest.PSObject.Properties[$Key]
    if (-not $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        throw "Missing '$Key' in $ManifestPath"
    }
    [string]$property.Value
}

function Read-ModIdentity {
    param([Parameter(Mandatory)][string]$ManifestPath)

    $manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $namespace = Get-ManifestValue $manifest 'namespace' $ManifestPath
    $name = Get-ManifestValue $manifest 'name' $ManifestPath
    [pscustomobject]@{
        ModId   = "$namespace-$name"
        Version = Get-ManifestValue $manifest 'version_number' $ManifestPath
    }
}

function Remove-ModZip {
    param(
        [Parameter(Mandatory)][string]$Directory,
        [Parameter(Mandatory)][string]$ModId
    )

    $versionedZipPattern = '^{0}-\d+\.\d+\.\d+\.zip$' -f [regex]::Escape($ModId)
    Get-ChildItem -LiteralPath $Directory -Filter "$ModId-*.zip" -File |
        Where-Object { $_.Name -match $versionedZipPattern } |
        Remove-Item
}

function New-ModZip {
    param(
        [Parameter(Mandatory)][System.IO.DirectoryInfo]$ModDirectory,
        [Parameter(Mandatory)][string]$ZipPath
    )

    $entryRoot = "$ZipModsRoot/$($ModDirectory.Name)/"
    $archive = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        [void]$archive.CreateEntry("$ZipModsRoot/")
        [void]$archive.CreateEntry($entryRoot)
        foreach ($modItem in Get-ModItem -ModDirectory $ModDirectory) {
            $entryName = $entryRoot + $modItem.RelativePath
            if ($modItem.Item.PSIsContainer) {
                [void]$archive.CreateEntry("$entryName/")
            }
            else {
                [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $modItem.Item.FullName, $entryName)
            }
        }
    }
    finally {
        $archive.Dispose()
    }
}

$outputRoot = New-Item -ItemType Directory -Path $OutputDirectory -Force

foreach ($modDirectory in Get-ModDirectory -Path $SourceDirectory) {
    $identity = Read-ModIdentity -ManifestPath (Join-Path $modDirectory.FullName $ManifestFileName)
    $author = Get-ModAuthor -ModDirectory $modDirectory
    $authorDirectory = New-Item -ItemType Directory -Path (Join-Path $outputRoot.FullName $author) -Force
    $zipName = "$($identity.ModId)-$($identity.Version).zip"
    Remove-ModZip -Directory $authorDirectory.FullName -ModId $identity.ModId
    New-ModZip -ModDirectory $modDirectory -ZipPath (Join-Path $authorDirectory.FullName $zipName)
    Write-Host "Packed: $author/$zipName"
}

& (Join-Path $PSScriptRoot 'nexus-descriptions.ps1') -SourceDirectory $SourceDirectory -OutputDirectory (Join-Path $outputRoot.FullName $NexusDirectoryName)
