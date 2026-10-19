Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

$RepositoryRoot = Split-Path $PSScriptRoot -Parent
$DefaultSourceDirectory = Join-Path $RepositoryRoot 'src'
$DefaultZipDirectory = Join-Path $RepositoryRoot 'out'
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
        [pscustomobject]@{
            Item         = $item
            RelativePath = $item.FullName.Substring($ModDirectory.FullName.Length + 1).Replace('\', '/')
        }
    }
}
