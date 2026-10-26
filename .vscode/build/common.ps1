Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

$RepositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$DefaultSourceDirectory = Join-Path $RepositoryRoot 'src'
$DefaultZipDirectory = Join-Path $RepositoryRoot 'out'
$NexusDirectoryName = 'nexus'
$MediaDirectoryName = 'media'
$ZipModsRoot = 'mods-unpacked'
$ManifestFileName = 'manifest.json'

function Get-ModDirectory {
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

function Get-ModAuthor {
    param([Parameter(Mandatory)][System.IO.DirectoryInfo]$ModDirectory)

    $ModDirectory.Parent.Name
}

function Get-ModItem {
    param([Parameter(Mandatory)][System.IO.DirectoryInfo]$ModDirectory)

    foreach ($item in Get-ChildItem -LiteralPath $ModDirectory.FullName -Recurse) {
        $relativePath = $item.FullName.Substring($ModDirectory.FullName.Length + 1).Replace('\', '/')
        if ($relativePath.Split('/')[0] -eq $MediaDirectoryName) { continue }
        [pscustomobject]@{
            Item         = $item
            RelativePath = $relativePath
        }
    }
}
