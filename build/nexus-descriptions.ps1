<#
.SYNOPSIS
Converts the README of every mod in .github/nexus-mods.json into the BBCode of its Nexus Mods description.

.DESCRIPTION
Nexus Mods descriptions are BBCode and have no tables, so each mod's README.md is converted: headings become sizes, tables become lists, inline code becomes bold and relative links point to the file on GitHub. Each description is written to <OutputDirectory>/<namespace>-<name>.txt, ready to paste into the description editor in BBCode mode.

The converter handles the Markdown the mod READMEs use: headings, paragraphs, bold, italic, inline code, links, lists (nested by indentation), blockquotes, tables, horizontal rules and fenced code blocks.

build.ps1 runs this script after packing the zips. Run it on its own to regenerate only the descriptions.

.PARAMETER SourceDirectory
Folder holding the author folders. Defaults to src/ in the repository root.

.PARAMETER OutputDirectory
Folder the descriptions are written to. Defaults to out/nexus/ in the repository root.

.EXAMPLE
./build/nexus-descriptions.ps1
#>
[CmdletBinding()]
param(
    [string]$SourceDirectory,
    [string]$OutputDirectory
)

. (Join-Path $PSScriptRoot 'common.ps1')

if (-not $SourceDirectory) { $SourceDirectory = $DefaultSourceDirectory }
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $DefaultZipDirectory $NexusDirectoryName }

$RepositoryUrl = 'https://github.com/Der-Floh/coal-llc-mods'
$NexusModsFile = Join-Path $RepositoryRoot '.github/nexus-mods.json'
$ReadmeFileName = 'README.md'
$ProseColumns = 'Description', 'Effect'
$CodePlaceholder = [char]0xE000

function ConvertTo-BBCodeInline {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory)][string]$LinkBase
    )

    $codeSpans = [System.Collections.Generic.List[string]]::new()
    $result = [regex]::Replace($Text, '`([^`]+)`', {
            param($match)
            $codeSpans.Add($match.Groups[1].Value)
            "$CodePlaceholder$($codeSpans.Count - 1)$CodePlaceholder"
        })
    $result = [regex]::Replace($result, '\[([^\]]+)\]\(([^)\s]+)\)', {
            param($match)
            "[url=$(Resolve-LinkTarget -Target $match.Groups[2].Value -LinkBase $LinkBase)]$($match.Groups[1].Value)[/url]"
        })
    $result = [regex]::Replace($result, '\*\*(.+?)\*\*', '[b]$1[/b]')
    $result = [regex]::Replace($result, '(?<![*\w])\*(?![\s*])(.+?)(?<![\s*])\*(?![*\w])', '[i]$1[/i]')
    $result = [regex]::Replace($result, '<br\s*/?>', "`n")
    [regex]::Replace($result, "$CodePlaceholder(\d+)$CodePlaceholder", {
            param($match)
            "[b]$($codeSpans[[int]$match.Groups[1].Value])[/b]"
        })
}

function Resolve-LinkTarget {
    param(
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$LinkBase
    )

    if ($Target -match '^[a-z][a-z0-9+.-]*:') { return $Target }
    if ($Target.StartsWith('#')) { return "$LinkBase$ReadmeFileName$Target" }
    [System.Uri]::new([System.Uri]$LinkBase, $Target).AbsoluteUri
}

function Test-BlockStart {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Line)

    $Line -match '^\s*(#{1,6}\s|>|\||```|([-*+]|\d+\.)\s|(-{3,}|\*{3,})\s*$)'
}

function Split-TableRow {
    param([Parameter(Mandatory)][string]$Line)

    @($Line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() })
}

function ConvertFrom-MarkdownTable {
    param(
        [Parameter(Mandatory)][string[]]$Lines,
        [Parameter(Mandatory)][string]$LinkBase
    )

    $headers = Split-TableRow -Line $Lines[0]
    $items = foreach ($row in $Lines | Select-Object -Skip 2) {
        $cells = Split-TableRow -Line $row
        $details = [System.Collections.Generic.List[string]]::new()
        $prose = [System.Collections.Generic.List[string]]::new()
        for ($column = 1; $column -lt $cells.Count; $column++) {
            if ([string]::IsNullOrWhiteSpace($cells[$column]) -or $cells[$column] -eq '-') { continue }
            $value = ConvertTo-BBCodeInline -Text $cells[$column] -LinkBase $LinkBase
            if ($ProseColumns -contains $headers[$column]) { $prose.Add($value) }
            else { $details.Add("$($headers[$column].ToLowerInvariant()) $value") }
        }
        $label = ConvertTo-BBCodeInline -Text $cells[0] -LinkBase $LinkBase
        if ($label -notmatch '^\[b\][^\[]*\[/b\]$') { $label = "[b]$label[/b]" }
        $item = "[*]$label"
        if ($details.Count -gt 0) { $item += " ($($details -join '; '))" }
        if ($prose.Count -gt 0) { $item += ": $($prose -join ' ')" }
        $item
    }
    "[list]$($items -join "`n")`n[/list]"
}

function ConvertFrom-MarkdownList {
    param(
        [Parameter(Mandatory)][string[]]$Lines,
        [Parameter(Mandatory)][string]$LinkBase
    )

    $entries = foreach ($line in $Lines) {
        if ($line -match '^(\s*)(?:([-*+])|\d+\.)\s+(.*)$') {
            [pscustomobject]@{ Indent = $Matches[1].Length; Ordered = -not $Matches[2]; Text = $Matches[3] }
        }
        else {
            [pscustomobject]@{ Indent = -1; Ordered = $false; Text = $line.Trim() }
        }
    }
    (ConvertFrom-ListEntries -Entries @($entries) -LinkBase $LinkBase).Text
}

function ConvertFrom-ListEntries {
    param(
        [Parameter(Mandatory)][object[]]$Entries,
        [Parameter(Mandatory)][string]$LinkBase,
        [int]$Start = 0
    )

    $indent = $Entries[$Start].Indent
    $opening = if ($Entries[$Start].Ordered) { '[list=1]' } else { '[list]' }
    $items = [System.Collections.Generic.List[string]]::new()
    $index = $Start
    while ($index -lt $Entries.Count) {
        $entry = $Entries[$index]
        if ($entry.Indent -ge 0 -and $entry.Indent -lt $indent) { break }
        if ($entry.Indent -gt $indent) {
            $nested = ConvertFrom-ListEntries -Entries $Entries -LinkBase $LinkBase -Start $index
            $items[$items.Count - 1] += "`n$($nested.Text)"
            $index = $nested.Next
            continue
        }
        if ($entry.Indent -lt 0) {
            $items[$items.Count - 1] += " $(ConvertTo-BBCodeInline -Text $entry.Text -LinkBase $LinkBase)"
        }
        else {
            $items.Add("[*]$(ConvertTo-BBCodeInline -Text $entry.Text -LinkBase $LinkBase)")
        }
        $index++
    }
    [pscustomobject]@{ Text = "$opening$($items -join "`n")`n[/list]"; Next = $index }
}

function ConvertTo-NexusBBCode {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string[]]$Lines,
        [Parameter(Mandatory)][string]$LinkBase
    )

    $blocks = [System.Collections.Generic.List[string]]::new()
    $index = 0
    while ($index -lt $Lines.Count) {
        $line = $Lines[$index]
        if ($line -match '^\s*$') {
            $index++
        }
        elseif ($line -match '^\s*```') {
            $code = [System.Collections.Generic.List[string]]::new()
            $index++
            while ($index -lt $Lines.Count -and $Lines[$index] -notmatch '^\s*```') {
                $code.Add($Lines[$index])
                $index++
            }
            $index++
            $blocks.Add("[code]$($code -join "`n")[/code]")
        }
        elseif ($line -match '^(#{1,6})\s+(.+?)\s*$') {
            $level = $Matches[1].Length
            $title = ConvertTo-BBCodeInline -Text $Matches[2] -LinkBase $LinkBase
            $index++
            $blocks.Add($(switch ($level) {
                        1 { "[size=6][b]$title[/b][/size]" }
                        2 { "[size=5][b]$title[/b][/size]" }
                        3 { "[size=4][b]$title[/b][/size]" }
                        default { "[b]$title[/b]" }
                    }))
        }
        elseif ($line -match '^\s*(-{3,}|\*{3,})\s*$') {
            $blocks.Add('[line]')
            $index++
        }
        elseif ($line -match '^\s*>') {
            $quote = [System.Collections.Generic.List[string]]::new()
            while ($index -lt $Lines.Count -and $Lines[$index] -match '^\s*>') {
                $quote.Add(($Lines[$index] -replace '^\s*> ?', ''))
                $index++
            }
            $inner = ConvertTo-NexusBBCode -Lines $quote.ToArray() -LinkBase $LinkBase
            $blocks.Add("[quote]$inner[/quote]")
        }
        elseif ($line -match '^\s*\|' -and $index + 1 -lt $Lines.Count -and $Lines[$index + 1] -match '^\s*\|?\s*:?-{3,}') {
            $table = [System.Collections.Generic.List[string]]::new()
            while ($index -lt $Lines.Count -and $Lines[$index] -match '^\s*\|') {
                $table.Add($Lines[$index])
                $index++
            }
            $blocks.Add((ConvertFrom-MarkdownTable -Lines $table.ToArray() -LinkBase $LinkBase))
        }
        elseif ($line -match '^\s*([-*+]|\d+\.)\s') {
            $list = [System.Collections.Generic.List[string]]::new()
            while ($index -lt $Lines.Count -and ($Lines[$index] -match '^\s*([-*+]|\d+\.)\s' -or ($Lines[$index] -match '^\s+\S' -and $list.Count -gt 0))) {
                $list.Add($Lines[$index])
                $index++
            }
            $blocks.Add((ConvertFrom-MarkdownList -Lines $list.ToArray() -LinkBase $LinkBase))
        }
        else {
            $paragraph = [System.Collections.Generic.List[string]]::new()
            while ($index -lt $Lines.Count -and $Lines[$index] -notmatch '^\s*$' -and -not ($paragraph.Count -gt 0 -and (Test-BlockStart -Line $Lines[$index]))) {
                $paragraph.Add($Lines[$index].Trim())
                $index++
            }
            $blocks.Add((ConvertTo-BBCodeInline -Text ($paragraph -join ' ') -LinkBase $LinkBase))
        }
    }
    $blocks -join "`n`n"
}

$nexusMods = Get-Content -LiteralPath $NexusModsFile -Raw -Encoding UTF8 | ConvertFrom-Json
$modIds = @($nexusMods.PSObject.Properties.Name)
$modDirectories = @(Get-ModDirectory -Path $SourceDirectory | Where-Object { $modIds -contains $_.Name })
$missing = @($modIds | Where-Object { $modDirectories.Name -notcontains $_ })
if ($missing.Count -gt 0) {
    throw "No mod folder in $SourceDirectory for $($missing -join ', ') from $NexusModsFile"
}

$outputRoot = New-Item -ItemType Directory -Path $OutputDirectory -Force
$utf8 = [System.Text.UTF8Encoding]::new($false)

foreach ($modDirectory in $modDirectories) {
    $readmePath = Join-Path $modDirectory.FullName $ReadmeFileName
    if (-not (Test-Path -LiteralPath $readmePath -PathType Leaf)) {
        throw "$($modDirectory.Name) has no $ReadmeFileName"
    }
    $author = Get-ModAuthor -ModDirectory $modDirectory
    $linkBase = "$RepositoryUrl/blob/main/src/$author/$($modDirectory.Name)/"
    $lines = (Get-Content -LiteralPath $readmePath -Raw -Encoding UTF8).TrimStart([char]0xFEFF) -split '\r?\n'
    $description = ConvertTo-NexusBBCode -Lines $lines -LinkBase $linkBase
    $outputPath = Join-Path $outputRoot.FullName "$($modDirectory.Name).txt"
    [System.IO.File]::WriteAllText($outputPath, "$description`n", $utf8)
    Write-Host "Converted: $author/$($modDirectory.Name)/$ReadmeFileName -> $($modDirectory.Name).txt"
}
