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
# Other authors' mods, kept only for reference and for integration tests; never built, validated or published.
$ThirdPartyDirectoryName = 'ThirdParty'

function Get-ModDirectory {
    param([Parameter(Mandatory)][string]$Path)

    $modDirectories = @(
        Get-ChildItem -LiteralPath $Path -Directory |
            Where-Object Name -ne $ThirdPartyDirectoryName |
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

# Packs a mod folder under mods-unpacked/<ModFolderName>/, the layout GML expects; the folder name must be the mod id.
function New-ModZip {
    param(
        [Parameter(Mandatory)][System.IO.DirectoryInfo]$ModDirectory,
        [Parameter(Mandatory)][string]$ZipPath,
        [string]$ModFolderName = $ModDirectory.Name
    )

    $entryRoot = "$ZipModsRoot/$ModFolderName/"
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
