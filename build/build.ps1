<#
.SYNOPSIS
Packs every mod in src/<author>/<mod>/ into a zip for Godot Mod Loader.

.DESCRIPTION
Each zip is named <namespace>-<name>-<version_number>.zip from the mod's manifest.json and holds the mod folder under mods-unpacked/, the layout GML expects.

.PARAMETER SourceDirectory
Folder holding the author folders. Defaults to src/ in the repository root.

.PARAMETER OutputDirectory
Folder the zips are written to; existing zips with the same name are replaced. Defaults to out/ in the repository root.

.EXAMPLE
./build/build.ps1 -OutputDirectory ./dist
#>
[CmdletBinding()]
param(
    [string]$SourceDirectory,
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Windows PowerShell 5.1 leaves $PSScriptRoot empty in param() defaults when run with -File.
$RepositoryRoot = Split-Path $PSScriptRoot -Parent
if (-not $SourceDirectory) { $SourceDirectory = Join-Path $RepositoryRoot 'src' }
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $RepositoryRoot 'out' }

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

$ZipModsRoot = 'mods-unpacked'
$ManifestFileName = 'manifest.json'

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

function Get-ModZipName {
    param([Parameter(Mandatory)][string]$ManifestPath)

    $manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $namespace = Get-ManifestValue $manifest 'namespace' $ManifestPath
    $name = Get-ManifestValue $manifest 'name' $ManifestPath
    $version = Get-ManifestValue $manifest 'version_number' $ManifestPath
    "$namespace-$name-$version.zip"
}

function Get-ModDirectories {
    param([Parameter(Mandatory)][string]$Path)

    $modDirectories = @(
        Get-ChildItem -LiteralPath $Path -Directory |
            Get-ChildItem -Directory |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName $ManifestFileName) -PathType Leaf } |
            Sort-Object FullName
    )
    if ($modDirectories.Count -eq 0) {
        throw "No mods found in $Path (expected <author>/<mod>/$ManifestFileName)"
    }
    $modDirectories
}

function New-ModZip {
    param(
        [Parameter(Mandatory)][System.IO.DirectoryInfo]$ModDirectory,
        [Parameter(Mandatory)][string]$ZipPath
    )

    if (Test-Path -LiteralPath $ZipPath) {
        Remove-Item -LiteralPath $ZipPath
    }

    $entryRoot = "$ZipModsRoot/$($ModDirectory.Name)/"
    $archive = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        [void]$archive.CreateEntry("$ZipModsRoot/")
        [void]$archive.CreateEntry($entryRoot)
        foreach ($item in Get-ChildItem -LiteralPath $ModDirectory.FullName -Recurse) {
            $relativePath = $item.FullName.Substring($ModDirectory.FullName.Length + 1).Replace('\', '/')
            if ($item.PSIsContainer) {
                [void]$archive.CreateEntry("$entryRoot$relativePath/")
            }
            else {
                [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $item.FullName, "$entryRoot$relativePath")
            }
        }
    }
    finally {
        $archive.Dispose()
    }
}

$outputRoot = New-Item -ItemType Directory -Path $OutputDirectory -Force

foreach ($modDirectory in Get-ModDirectories -Path $SourceDirectory) {
    $zipName = Get-ModZipName -ManifestPath (Join-Path $modDirectory.FullName $ManifestFileName)
    New-ModZip -ModDirectory $modDirectory -ZipPath (Join-Path $outputRoot.FullName $zipName)
    Write-Host "Packed: $zipName"
}
