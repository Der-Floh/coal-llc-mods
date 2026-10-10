<#
.SYNOPSIS
Checks the zips built by build.ps1 against the mod sources and against what Godot Mod Loader needs to load them.

.DESCRIPTION
Every mod in src/<author>/<mod>/ needs exactly one zip, and every zip must:
- contain the files of its source folder, unchanged, and nothing else,
- keep them under mods-unpacked/<namespace>-<name>/ with '/' separators,
- include mod_main.gd and a manifest.json that passes the checks of GML 7.0.1 (NanobotZ build),
- be named <namespace>-<name>-<version_number>.zip,
- contain every res://mods-unpacked/ file and hook script its scripts refer to, and refer to every hook script it ships.

.PARAMETER SourceDirectory
Folder holding the author folders. Defaults to src/ in the repository root.

.PARAMETER ZipDirectory
Folder holding the zips to check. Defaults to out/ in the repository root.
#>
[CmdletBinding()]
param(
    [string]$SourceDirectory,
    [string]$ZipDirectory
)

. (Join-Path $PSScriptRoot 'common.ps1')

if (-not $SourceDirectory) { $SourceDirectory = $DefaultSourceDirectory }
if (-not $ZipDirectory) { $ZipDirectory = $DefaultZipDirectory }

$ModMainFileName = 'mod_main.gd'
$HookScriptSuffix = '.hooks.gd'
$RequiredManifestKeys = 'name', 'namespace', 'version_number', 'website_url', 'description', 'dependencies', 'extra'
$RequiredGodotKeys = 'authors', 'compatible_mod_loader_version', 'compatible_game_version'
$ModIdListKeys = 'dependencies', 'optional_dependencies', 'incompatibilities', 'load_before'
$DistinctModIdListPairs = @(
    @('dependencies', 'incompatibilities'),
    @('optional_dependencies', 'dependencies'),
    @('optional_dependencies', 'incompatibilities'),
    @('load_before', 'dependencies'),
    @('load_before', 'optional_dependencies'),
    @('load_before', 'incompatibilities')
)
$ModIdPartPattern = '^[a-zA-Z0-9_]{3,}$'
$SemverPattern = '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
$MaxVersionLength = 16
$ScriptEntryPattern = '\.(gd|tscn|tres)$'
$ModReferencePattern = 'res://mods-unpacked/([A-Za-z0-9_-]+)/([^"''\s)\]},;]+)'
$HookPathPattern = '"([A-Za-z0-9_./-]+\.hooks\.gd)"'

function New-OrdinalDictionary {
    [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
}

function Get-Sha256 {
    param([Parameter(Mandatory)][AllowEmptyCollection()][byte[]]$Bytes)

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        [System.BitConverter]::ToString($sha256.ComputeHash($Bytes)).Replace('-', '')
    }
    finally {
        $sha256.Dispose()
    }
}

function Read-ZipEntryBytes {
    param([Parameter(Mandatory)][System.IO.Compression.ZipArchiveEntry]$Entry)

    $source = $Entry.Open()
    $buffer = [System.IO.MemoryStream]::new()
    try {
        $source.CopyTo($buffer)
        , $buffer.ToArray()
    }
    finally {
        $source.Dispose()
        $buffer.Dispose()
    }
}

function ConvertFrom-Utf8 {
    param([Parameter(Mandatory)][AllowEmptyCollection()][byte[]]$Bytes)

    [System.Text.Encoding]::UTF8.GetString($Bytes).TrimStart([char]0xFEFF)
}

function Read-ModZip {
    param([Parameter(Mandatory)][System.IO.FileInfo]$ZipFile)

    $files = New-OrdinalDictionary
    $directories = [System.Collections.Generic.List[string]]::new()
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ZipFile.FullName)
    try {
        foreach ($entry in $archive.Entries) {
            if ($entry.FullName.EndsWith('/')) {
                $directories.Add($entry.FullName)
            }
            else {
                $files[$entry.FullName] = Read-ZipEntryBytes -Entry $entry
            }
        }
    }
    finally {
        $archive.Dispose()
    }

    $entryNames = @($files.Keys) + @($directories)
    [pscustomobject]@{
        ZipName    = $ZipFile.Name
        Files      = $files
        EntryNames = $entryNames
        ModFolders = @(
            $entryNames |
                Where-Object { $_.StartsWith("$ZipModsRoot/", [System.StringComparison]::Ordinal) } |
                ForEach-Object { ($_ -split '/')[1] } |
                Where-Object { $_ } |
                Sort-Object -CaseSensitive -Unique
        )
        Scripts    = @(
            $files.Keys |
                Where-Object { $_ -match $ScriptEntryPattern } |
                ForEach-Object { [pscustomobject]@{ EntryName = $_; Text = ConvertFrom-Utf8 -Bytes $files[$_] } }
        )
    }
}

function Get-JsonProperty {
    param($Object, [Parameter(Mandatory)][string]$Key)

    if ($Object -is [System.Management.Automation.PSCustomObject]) {
        $Object.PSObject.Properties | Where-Object { $_.Name -ceq $Key } | Select-Object -First 1
    }
}

function Get-JsonValue {
    param($Object, [Parameter(Mandatory)][string]$Key)

    $property = Get-JsonProperty $Object $Key
    if ($property) {
        $property.Value
    }
}

function Test-ModIdPart {
    param($Value)

    $Value -is [string] -and $Value -match $ModIdPartPattern
}

function Test-Semver {
    param($Value)

    $Value -is [string] -and $Value -match $SemverPattern -and $Value.Length -le $MaxVersionLength
}

function Test-ModId {
    param($Value)

    $parts = @("$Value" -split '-')
    $Value -is [string] -and $parts.Count -eq 2 -and (Test-ModIdPart $parts[0]) -and (Test-ModIdPart $parts[1])
}

function Test-ZipPath {
    param([Parameter(Mandatory)]$Package, [Parameter(Mandatory)][string]$Path)

    if ($Package.Files.ContainsKey($Path)) {
        return $true
    }
    $folderPrefix = $Path.TrimEnd('/') + '/'
    [bool]($Package.EntryNames | Where-Object { $_.StartsWith($folderPrefix, [System.StringComparison]::Ordinal) } | Select-Object -First 1)
}

function Test-ZipLayout {
    param([Parameter(Mandatory)]$Package)

    $backslashEntries = @($Package.EntryNames | Where-Object { $_.Contains('\') })
    if ($backslashEntries.Count -gt 0) {
        "$($backslashEntries.Count) entries use '\' separators (first: '$($backslashEntries[0])'); GML only finds paths separated by '/'"
    }
    foreach ($entryName in $Package.EntryNames) {
        if ($entryName.Contains('\')) {
            continue
        }
        if (-not $entryName.StartsWith("$ZipModsRoot/", [System.StringComparison]::Ordinal)) {
            "entry '$entryName' is outside $ZipModsRoot/"
        }
        elseif (($entryName -split '/') -contains '..') {
            "entry '$entryName' contains '..'"
        }
    }

    if ($Package.ModFolders.Count -ne 1) {
        "expected one mod folder in $ZipModsRoot/, found $($Package.ModFolders.Count): $($Package.ModFolders -join ', ')"
        return
    }
    foreach ($requiredFile in $ModMainFileName, $ManifestFileName) {
        $requiredPath = "$ZipModsRoot/$($Package.ModFolders[0])/$requiredFile"
        if (-not $Package.Files.ContainsKey($requiredPath)) {
            "missing $requiredPath"
        }
    }
}

function Test-CompatibleVersion {
    param($Godot)

    $loaderVersions = Get-JsonProperty $Godot 'compatible_mod_loader_version'
    if ($loaderVersions) {
        $versions = @($loaderVersions.Value)
        $isValidList = $loaderVersions.Value -is [array] -and $versions.Count -gt 0 -and @($versions | Where-Object { -not (Test-Semver $_) }).Count -eq 0
        $isValidString = $loaderVersions.Value -is [string] -and $loaderVersions.Value -ne ''
        if (-not ($isValidList -or $isValidString)) {
            "manifest 'extra.godot.compatible_mod_loader_version' must list mod loader versions like 7.0.1"
        }
    }

    $gameVersions = Get-JsonProperty $Godot 'compatible_game_version'
    if ($gameVersions -and -not ($gameVersions.Value -is [array] -and @($gameVersions.Value).Count -gt 0)) {
        "manifest 'extra.godot.compatible_game_version' must list at least one game version"
    }
}

function Test-ModIdList {
    param($Manifest, $Godot, [Parameter(Mandatory)][string]$ModId)

    $dependencies = Get-JsonProperty $Manifest 'dependencies'
    if ($dependencies -and $dependencies.Value -isnot [array]) {
        "manifest 'dependencies' must be a list"
    }

    $lists = @{}
    foreach ($key in $ModIdListKeys) {
        $owner = if ($key -eq 'dependencies') { $Manifest } else { $Godot }
        $lists[$key] = @(Get-JsonValue $owner $key)
        foreach ($listedModId in $lists[$key]) {
            if ($listedModId -ceq $ModId) {
                "manifest lists the mod itself in '$key'"
            }
            elseif (-not (Test-ModId $listedModId)) {
                "manifest '$key' entry '$listedModId' is not a valid <namespace>-<name> mod ID"
            }
        }
    }

    foreach ($pair in $DistinctModIdListPairs) {
        $overlap = @($lists[$pair[0]] | Where-Object { $lists[$pair[1]] -ccontains $_ })
        if ($overlap.Count -gt 0) {
            "manifest lists $($overlap -join ', ') in both '$($pair[0])' and '$($pair[1])'"
        }
    }
}

function Test-Manifest {
    param(
        [Parameter(Mandatory)]$Manifest,
        [Parameter(Mandatory)][string]$ModFolder,
        [Parameter(Mandatory)][string]$ZipName
    )

    $godot = Get-JsonValue (Get-JsonValue $Manifest 'extra') 'godot'
    $missingKeys = @(
        $RequiredManifestKeys | Where-Object { -not (Get-JsonProperty $Manifest $_) }
        if ($godot) {
            $RequiredGodotKeys | Where-Object { -not (Get-JsonProperty $godot $_) } | ForEach-Object { "extra.godot.$_" }
        }
        else {
            'extra.godot'
        }
    )
    if ($missingKeys.Count -gt 0) {
        "manifest is missing required fields: $($missingKeys -join ', ')"
    }

    $namespace = Get-JsonValue $Manifest 'namespace'
    $name = Get-JsonValue $Manifest 'name'
    $version = Get-JsonValue $Manifest 'version_number'
    if (-not (Test-ModIdPart $namespace)) {
        "manifest 'namespace' must be at least 3 letters, digits or underscores, but is '$namespace'"
    }
    if (-not (Test-ModIdPart $name)) {
        "manifest 'name' must be at least 3 letters, digits or underscores, but is '$name'"
    }
    if (-not (Test-Semver $version)) {
        "manifest 'version_number' must be a version like 1.2.3, but is '$version'"
    }

    $modId = "$namespace-$name"
    if ($ModFolder -cne $modId) {
        "mod folder '$ModFolder' does not match the manifest's <namespace>-<name> '$modId'"
    }
    if ($ZipName -cne "$modId-$version.zip") {
        "zip should be named '$modId-$version.zip' to match the manifest"
    }

    Test-CompatibleVersion -Godot $godot
    Test-ModIdList -Manifest $Manifest -Godot $godot -ModId $modId
}

function Test-ManifestEntry {
    param([Parameter(Mandatory)]$Package, [Parameter(Mandatory)][string]$ModFolder)

    $manifestPath = "$ZipModsRoot/$ModFolder/$ManifestFileName"
    if (-not $Package.Files.ContainsKey($manifestPath)) {
        return
    }
    try {
        $manifest = ConvertFrom-Utf8 -Bytes $Package.Files[$manifestPath] | ConvertFrom-Json
    }
    catch {
        "manifest is not valid JSON: $($_.Exception.Message)"
        return
    }
    Test-Manifest -Manifest $manifest -ModFolder $ModFolder -ZipName $Package.ZipName
}

function Test-MatchesSource {
    param([Parameter(Mandatory)]$Package, [Parameter(Mandatory)][System.IO.DirectoryInfo]$ModDirectory)

    $entryRoot = "$ZipModsRoot/$($ModDirectory.Name)/"
    $sourceFiles = New-OrdinalDictionary
    foreach ($modItem in Get-ModItem -ModDirectory $ModDirectory) {
        if (-not $modItem.Item.PSIsContainer) {
            $sourceFiles[$entryRoot + $modItem.RelativePath] = $modItem.Item.FullName
        }
    }

    foreach ($entryName in $sourceFiles.Keys) {
        if (-not $Package.Files.ContainsKey($entryName)) {
            "$entryName is in src but missing from the zip"
        }
        elseif ((Get-Sha256 -Bytes ([System.IO.File]::ReadAllBytes($sourceFiles[$entryName]))) -ne (Get-Sha256 -Bytes $Package.Files[$entryName])) {
            "$entryName differs from its source file"
        }
    }
    foreach ($entryName in $Package.Files.Keys) {
        if (-not $sourceFiles.ContainsKey($entryName)) {
            "$entryName is in the zip but not in src"
        }
    }
}

function Test-ModReference {
    param([Parameter(Mandatory)]$Package, [Parameter(Mandatory)]$PackagesByModFolder)

    foreach ($script in $Package.Scripts) {
        foreach ($match in [regex]::Matches($script.Text, $ModReferencePattern)) {
            $targetModFolder = $match.Groups[1].Value
            $targetPath = "$ZipModsRoot/$targetModFolder/$($match.Groups[2].Value)"
            if ($targetPath -match '[%{$]' -or -not $PackagesByModFolder.ContainsKey($targetModFolder)) {
                continue
            }
            $targetPackage = $PackagesByModFolder[$targetModFolder]
            if (-not (Test-ZipPath -Package $targetPackage -Path $targetPath)) {
                "$($script.EntryName) refers to res://$targetPath, which is not in $($targetPackage.ZipName)"
            }
        }
    }
}

function Test-HookScript {
    param([Parameter(Mandatory)]$Package)

    $hookScripts = @($Package.Files.Keys | Where-Object { $_.EndsWith($HookScriptSuffix, [System.StringComparison]::Ordinal) })
    $referencedHookScripts = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($script in $Package.Scripts) {
        foreach ($match in [regex]::Matches($script.Text, $HookPathPattern)) {
            $hookPath = $match.Groups[1].Value
            $matchingHookScripts = @($hookScripts | Where-Object { $_.EndsWith("/$hookPath", [System.StringComparison]::Ordinal) })
            if ($matchingHookScripts.Count -eq 0) {
                "$($script.EntryName) refers to hook script '$hookPath', which is not in the zip"
            }
            foreach ($hookScript in $matchingHookScripts) {
                [void]$referencedHookScripts.Add($hookScript)
            }
        }
        foreach ($match in [regex]::Matches($script.Text, $ModReferencePattern)) {
            [void]$referencedHookScripts.Add("$ZipModsRoot/$($match.Groups[1].Value)/$($match.Groups[2].Value)")
        }
    }

    foreach ($hookScript in $hookScripts) {
        if (-not $referencedHookScripts.Contains($hookScript)) {
            "$hookScript is never installed: no script refers to it"
        }
    }
}

function Test-ModZip {
    param(
        [Parameter(Mandatory)]$Package,
        [Parameter(Mandatory)]$ModDirectoriesByName,
        [Parameter(Mandatory)]$PackagesByModFolder
    )

    Test-ZipLayout -Package $Package
    if ($Package.ModFolders.Count -ne 1) {
        return
    }

    $modFolder = $Package.ModFolders[0]
    Test-ManifestEntry -Package $Package -ModFolder $modFolder
    if ($ModDirectoriesByName.ContainsKey($modFolder)) {
        Test-MatchesSource -Package $Package -ModDirectory $ModDirectoriesByName[$modFolder]
    }
    else {
        "there is no src/<author>/$modFolder folder for this zip"
    }
    Test-ModReference -Package $Package -PackagesByModFolder $PackagesByModFolder
    Test-HookScript -Package $Package
}

function Test-ModInventory {
    param([Parameter(Mandatory)][System.IO.DirectoryInfo[]]$ModDirectories, [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Packages)

    $ModDirectories | Group-Object Name | Where-Object { $_.Count -gt 1 } | ForEach-Object {
        "mod folder name '$($_.Name)' is used by more than one author folder"
    }
    foreach ($modDirectory in $ModDirectories) {
        $modZips = @($Packages | Where-Object { $_.ModFolders -ccontains $modDirectory.Name })
        if ($modZips.Count -eq 0) {
            "src/$($modDirectory.Parent.Name)/$($modDirectory.Name) has no zip"
        }
        elseif ($modZips.Count -gt 1) {
            "src/$($modDirectory.Parent.Name)/$($modDirectory.Name) has $($modZips.Count) zips ($(@($modZips | ForEach-Object { $_.ZipName }) -join ', ')); delete the stale ones and rebuild"
        }
    }
}

if (-not (Test-Path -LiteralPath $ZipDirectory -PathType Container)) {
    throw "Nothing to check: $ZipDirectory does not exist. Run build.ps1 first."
}

$modDirectories = @(Get-ModDirectory -Path $SourceDirectory)
$modDirectoriesByName = New-OrdinalDictionary
foreach ($modDirectory in $modDirectories) {
    $modDirectoriesByName[$modDirectory.Name] = $modDirectory
}

$problemsByZip = [ordered]@{}
$packages = [System.Collections.Generic.List[object]]::new()
foreach ($zipFile in Get-ChildItem -LiteralPath $ZipDirectory -Filter '*.zip' -File | Sort-Object Name) {
    try {
        $packages.Add((Read-ModZip -ZipFile $zipFile))
        $problemsByZip[$zipFile.Name] = @()
    }
    catch {
        $problemsByZip[$zipFile.Name] = @("cannot be read as a zip: $($_.Exception.Message)")
    }
}

$packagesByModFolder = New-OrdinalDictionary
foreach ($package in $packages) {
    if ($package.ModFolders.Count -eq 1 -and -not $packagesByModFolder.ContainsKey($package.ModFolders[0])) {
        $packagesByModFolder[$package.ModFolders[0]] = $package
    }
}

foreach ($package in $packages) {
    $problemsByZip[$package.ZipName] = @(Test-ModZip -Package $package -ModDirectoriesByName $modDirectoriesByName -PackagesByModFolder $packagesByModFolder)
}
$inventoryProblems = @(Test-ModInventory -ModDirectories $modDirectories -Packages $packages.ToArray())

$failedZipCount = 0
foreach ($zipName in $problemsByZip.Keys) {
    $problems = $problemsByZip[$zipName]
    if ($problems.Count -eq 0) {
        Write-Host "OK    $zipName"
        continue
    }
    $failedZipCount++
    Write-Host "FAIL  $zipName"
    foreach ($problem in $problems) {
        Write-Host "      - $problem"
    }
}
foreach ($problem in $inventoryProblems) {
    Write-Host "FAIL  $problem"
}

if ($failedZipCount -gt 0 -or $inventoryProblems.Count -gt 0) {
    Write-Host "Validation failed: $failedZipCount of $($problemsByZip.Count) zip(s) have problems, plus $($inventoryProblems.Count) problem(s) with missing or duplicate mods."
    exit 1
}
Write-Host "All $($problemsByZip.Count) zips match their sources and the GML mod structure."
