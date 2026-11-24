<#
.SYNOPSIS
Runs the integration tests: each mod's tests inside the game, with the mod alone, with all mods, and in the combinations its suite declares.

.DESCRIPTION
A mod's tests live in tests/integration/<author>/<mod-id>/test_*.gd, and every func test_*() in them is one test. The tests in tests/integration/_common/ run in every session.

Every suite runs in two sessions: "solo" (its mod alone) and "all" (all mods in src/). Its suite.json can add more:
    { "sessions": [ { "name": "with-tick-upgrade", "mods": ["der_floh-tick_upgrade_mod"], "third_party": ["CoalLLC-AutoPassiveChooser"], "tests": ["test_bridge.gd"] } ] }
"mods" are other repo mods loaded with it, "third_party" names rows of src/ThirdParty/ThirdParty-Mods.csv (fetched when missing), and "tests" limits the files run there.

Sessions loading the same mods are merged and the largest runs first, so GML's hook pack grows once. Each session starts the game through tests/harness with default mod configs, runs its tests one at a time and stops; a test that hangs or crashes the game is reported and the session restarted.

Results go to the console and to tests/harness/run/results/ (integration.xml in JUnit format, summary.md, and the logs of sessions with failures). The exit code is 1 when any test did not pass.

.PARAMETER Mods
Only run the suites of these mods.

.PARAMETER Session
Only run these sessions: solo, all, or a session name from a suite.json.

.PARAMETER Test
Only run tests whose function or file name matches this wildcard.

.PARAMETER List
Only print the planned sessions and tests; the game isn't started.

.PARAMETER NoBuild
Use the zips of the previous build.

.PARAMETER TimeoutSec
How long one test may take before its session is restarted.

.PARAMETER GameDirectory
The folder with Coal LLC.exe; found through Steam when left out.

.EXAMPLE
./tests/run-integration.ps1 -Mods ingenitus-extra_passives_mod -Session solo
#>
[CmdletBinding()]
param(
    [string[]]$Mods,
    [string[]]$Session,
    [string]$Test = '*',
    [switch]$List,
    [switch]$NoBuild,
    [int]$TimeoutSec = 120,
    [string]$GameDirectory
)

. (Join-Path $PSScriptRoot '..\.vscode\build\common.ps1')
Import-Module (Join-Path $PSScriptRoot 'harness\Harness.psm1') -Force

$IntegrationDirectory = Join-Path $PSScriptRoot 'integration'
$CommonSuiteName = '_common'
$SuiteFileName = 'suite.json'
$TestFileFilter = 'test_*.gd'
$TestFunctionPattern = '(?m)^func (test_\w+)\('
$SoloSession = 'solo'
$AllSession = 'all'
$ThirdPartyDirectory = Join-Path $DefaultSourceDirectory $ThirdPartyDirectoryName
$ThirdPartyListFile = Join-Path $ThirdPartyDirectory 'ThirdParty-Mods.csv'
$FetchScript = Join-Path $PSScriptRoot 'fetch-third-party.ps1'
$ResultsDirectory = Join-Path (Get-HarnessRunDirectory) 'results'
$LogNames = 'godot.log', 'modloader.log'
$FailingStatuses = 'failed', 'error'
$StatusLabels = @{ passed = 'PASS'; failed = 'FAIL'; error = 'ERROR'; skipped = 'SKIP' }

# --- Suites and tests ---

function Get-RelativePath {
    param([Parameter(Mandatory)][string]$Path)

    $Path.Substring($RepositoryRoot.Length + 1).Replace('\', '/')
}

function Get-SuiteDefinition {
    param([Parameter(Mandatory)][System.IO.DirectoryInfo]$Directory)

    $suiteFile = Join-Path $Directory.FullName $SuiteFileName
    $sessions = @()
    if (Test-Path -LiteralPath $suiteFile) {
        $definition = Get-Content -LiteralPath $suiteFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($definition.PSObject.Properties['sessions']) { $sessions = @($definition.sessions) }
    }
    [pscustomobject]@{
        Name      = $Directory.Name
        Directory = $Directory
        Sessions  = $sessions
    }
}

function Get-Suite {
    $modDirectories = @(Get-ChildItem -LiteralPath $IntegrationDirectory -Directory | Where-Object Name -ne $CommonSuiteName | Get-ChildItem -Directory)
    $suites = @($modDirectories | ForEach-Object { Get-SuiteDefinition $_ })
    if ($Mods) { $suites = @($suites | Where-Object { $Mods -contains $_.Name }) }
    $suites
}

function Get-OptionalProperty {
    param([Parameter(Mandatory)][psobject]$Object, [Parameter(Mandatory)][string]$Name)

    if ($Object.PSObject.Properties[$Name]) { @($Object.$Name) } else { @() }
}

function Get-TestItem {
    param([Parameter(Mandatory)][psobject]$Suite, [string[]]$Files)

    foreach ($file in Get-ChildItem -LiteralPath $Suite.Directory.FullName -Filter $TestFileFilter -File | Sort-Object Name) {
        if ($Files -and $Files -notcontains $file.Name) { continue }
        $source = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
        foreach ($match in [regex]::Matches($source, $TestFunctionPattern)) {
            $function = $match.Groups[1].Value
            if ($function -notlike $Test -and $file.Name -notlike $Test) { continue }
            [pscustomobject]@{
                Suite    = $Suite.Name
                File     = $file
                Path     = Get-RelativePath $file.FullName
                Function = $function
            }
        }
    }
}

# --- Sessions ---

function Add-SessionTest {
    param(
        [Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$Plan,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string[]]$SessionMods,
        [string[]]$ThirdParty,
        [object[]]$Tests
    )

    if ($Session -and $Session -notcontains $Name) { return }
    if (-not $Tests) { return }
    $modSet = @($SessionMods | Sort-Object -Unique)
    $thirdPartySet = @($ThirdParty | Where-Object { $_ } | Sort-Object -Unique)
    $key = ($modSet + ($thirdPartySet | ForEach-Object { "third-party:$_" })) -join '|'
    if (-not $Plan.Contains($key)) {
        $Plan[$key] = [pscustomobject]@{
            Names      = [System.Collections.Generic.List[string]]::new()
            Mods       = $modSet
            ThirdParty = $thirdPartySet
            Tests      = [System.Collections.Generic.List[object]]::new()
        }
    }
    $entry = $Plan[$key]
    $label = if ($Name -eq $SoloSession -and $modSet.Count -eq 1) { "$SoloSession $($modSet[0])" } else { $Name }
    if (-not $entry.Names.Contains($label)) { $entry.Names.Add($label) }
    foreach ($item in $Tests) {
        if (-not @($entry.Tests | Where-Object { $_.Path -eq $item.Path -and $_.Function -eq $item.Function })) { $entry.Tests.Add($item) }
    }
}

function New-SessionPlan {
    param([Parameter(Mandatory)][object[]]$Suites, [Parameter(Mandatory)][string[]]$RepoMods)

    $plan = [ordered]@{}
    foreach ($suite in $Suites) {
        $tests = @(Get-TestItem $suite)
        Add-SessionTest -Plan $plan -Name $SoloSession -SessionMods @($suite.Name) -Tests $tests
        Add-SessionTest -Plan $plan -Name $AllSession -SessionMods $RepoMods -Tests $tests
        foreach ($definition in $suite.Sessions) {
            $extraMods = Get-OptionalProperty $definition 'mods'
            $unknown = @($extraMods | Where-Object { $RepoMods -notcontains $_ })
            if ($unknown) { throw "$($suite.Name)/$SuiteFileName session '$($definition.name)' names unknown mods: $($unknown -join ', ')" }
            $files = Get-OptionalProperty $definition 'tests'
            Add-SessionTest -Plan $plan -Name $definition.name -SessionMods (@($suite.Name) + $extraMods) -ThirdParty (Get-OptionalProperty $definition 'third_party') -Tests @(Get-TestItem $suite $files)
        }
    }
    $commonDirectory = Get-Item -LiteralPath (Join-Path $IntegrationDirectory $CommonSuiteName) -ErrorAction SilentlyContinue
    $commonTests = @(if ($commonDirectory) { Get-TestItem ([pscustomobject]@{ Name = $CommonSuiteName; Directory = $commonDirectory }) })
    foreach ($entry in $plan.Values) { $entry.Tests.InsertRange(0, [object[]]$commonTests) }
    @($plan.Values | Sort-Object -Property @{ Expression = { $_.Mods.Count + $_.ThirdParty.Count }; Descending = $true })
}

function Get-ThirdPartyZip {
    param([string[]]$Names)

    if (-not $Names) { return @() }
    $rows = @(Import-Csv -LiteralPath $ThirdPartyListFile)
    foreach ($name in $Names) {
        $row = $rows | Where-Object Name -eq $name | Select-Object -First 1
        if (-not $row) { throw "Third-party mod '$name' isn't listed in $ThirdPartyListFile." }
        $zip = Join-Path (Join-Path $ThirdPartyDirectory $row.Author) "$($row.Name).zip"
        if (-not (Test-Path -LiteralPath $zip)) { & $FetchScript -Name $name }
        if (-not (Test-Path -LiteralPath $zip)) { throw "No zip for third-party mod '$name' at $zip." }
        $zip
    }
}

# --- Running ---

function New-TestResult {
    param(
        [Parameter(Mandatory)][psobject]$Item,
        [Parameter(Mandatory)][string]$SessionName,
        [Parameter(Mandatory)][string]$Status,
        [string[]]$Messages,
        [int]$DurationMs
    )

    [pscustomobject]@{
        Session    = $SessionName
        Suite      = $Item.Suite
        File       = $Item.File.Name
        Function   = $Item.Function
        Status     = $Status
        Messages   = @($Messages | Where-Object { $_ })
        DurationMs = $DurationMs
    }
}

function Start-PlannedSession {
    param([Parameter(Mandatory)][psobject]$Entry, [switch]$Build)

    Clear-HarnessModConfig
    $extra = @(Get-ThirdPartyZip $Entry.ThirdParty)
    $started = Start-HarnessSession -Mods $Entry.Mods -Extra $extra -NoBuild:(-not $Build) -GameDirectory $GameDirectory
    $active = @($started.status.mods | Where-Object active | ForEach-Object id)
    $notLoaded = @($Entry.Mods | Where-Object { $active -notcontains $_ })
    if ($notLoaded) { throw "GML did not load: $($notLoaded -join ', '). See modloader.log." }
}

function Invoke-PlannedTest {
    param([Parameter(Mandatory)][psobject]$Item, [Parameter(Mandatory)][string]$SessionName)

    $arguments = @{ path = $Item.Path; source = (Get-Content -LiteralPath $Item.File.FullName -Raw -Encoding UTF8); function = $Item.Function }
    $response = Invoke-HarnessCommand -Name 'run_test' -Arguments $arguments -TimeoutSec $TimeoutSec
    if (-not $response.ok) { return New-TestResult $Item $SessionName 'error' @($response.error) }
    $result = $response.result
    $messages = if ($result.status -eq 'skipped') { @($result.skip_reason) } else { @($result.messages) }
    New-TestResult $Item $SessionName $result.status $messages $result.duration_ms
}

function Write-TestResult {
    param([Parameter(Mandatory)][psobject]$Result)

    $color = switch ($Result.Status) { 'passed' { 'Green' } 'skipped' { 'DarkYellow' } default { 'Red' } }
    Write-Host ("  {0,-5} {1}/{2}::{3} ({4:N1} s)" -f $StatusLabels[$Result.Status], $Result.Suite, $Result.File, $Result.Function, ($Result.DurationMs / 1000)) -ForegroundColor $color
    foreach ($message in $Result.Messages) { Write-Host "        $message" }
}

function Save-SessionLog {
    param([Parameter(Mandatory)][string]$SessionName)

    $target = New-Item -ItemType Directory -Path (Join-Path $ResultsDirectory ($SessionName -replace '[^\w.-]+', '_')) -Force
    foreach ($logName in $LogNames) {
        Copy-Item -LiteralPath (Join-Path (Get-HarnessTestProfile) "logs\$logName") -Destination $target.FullName -ErrorAction SilentlyContinue
    }
}

function Stop-PlannedSession {
    $stop = Stop-HarnessSession -GameDirectory $GameDirectory
    if (-not $stop.real_profile_unchanged) {
        throw "Your real profile changed during the tests: $($stop.changed_files -join ', '). Stopping; check it before running again."
    }
}

function Invoke-PlannedSession {
    param([Parameter(Mandatory)][psobject]$Entry, [switch]$Build)

    $name = $Entry.Names -join ', '
    $thirdParty = if ($Entry.ThirdParty) { " + $($Entry.ThirdParty -join ', ')" } else { '' }
    Write-Host "`n[$name] $($Entry.Mods.Count) mod(s)$thirdParty, $($Entry.Tests.Count) test(s)" -ForegroundColor Cyan
    $results = [System.Collections.Generic.List[object]]::new()
    try {
        Start-PlannedSession $Entry -Build:$Build
    }
    catch {
        foreach ($item in $Entry.Tests) { $results.Add((New-TestResult $item $name 'error' @("The session did not start: $($_.Exception.Message)"))) }
        Save-SessionLog $name
        Stop-PlannedSession
        return $results
    }
    $restartError = $null
    foreach ($item in $Entry.Tests) {
        if ($restartError) {
            $results.Add((New-TestResult $item $name 'error' @("Not run: the session could not be restarted ($restartError).")))
            continue
        }
        try {
            $result = Invoke-PlannedTest $item $name
        }
        catch {
            $result = New-TestResult $item $name 'error' @("No answer within $TimeoutSec s, or the game closed: $($_.Exception.Message)")
            Save-SessionLog $name
            Stop-PlannedSession
            try { Start-PlannedSession $Entry } catch { $restartError = $_.Exception.Message }
        }
        Write-TestResult $result
        $results.Add($result)
    }
    if ($restartError) { return $results }
    if (@($results | Where-Object { $FailingStatuses -contains $_.Status })) { Save-SessionLog $name }
    Stop-PlannedSession
    $results
}

# --- Reports ---

function ConvertTo-XmlText {
    param([string]$Text)

    [System.Security.SecurityElement]::Escape($Text)
}

function Format-Seconds {
    param([Parameter(Mandatory)][double]$Milliseconds)

    ($Milliseconds / 1000).ToString('0.###', [System.Globalization.CultureInfo]::InvariantCulture)
}

function Write-JUnitReport {
    param([Parameter(Mandatory)][object[]]$Results)

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('<?xml version="1.0" encoding="utf-8"?>')
    $lines.Add('<testsuites name="Coal LLC integration tests">')
    foreach ($group in $Results | Group-Object Session) {
        $failed = @($group.Group | Where-Object Status -eq 'failed').Count
        $errors = @($group.Group | Where-Object Status -eq 'error').Count
        $skipped = @($group.Group | Where-Object Status -eq 'skipped').Count
        $seconds = Format-Seconds ($group.Group | Measure-Object DurationMs -Sum).Sum
        $lines.Add(('  <testsuite name="{0}" tests="{1}" failures="{2}" errors="{3}" skipped="{4}" time="{5}">' -f (ConvertTo-XmlText $group.Name), $group.Count, $failed, $errors, $skipped, $seconds))
        foreach ($result in $group.Group) {
            $lines.Add(('    <testcase classname="{0}.{1}" name="{2}" time="{3}">' -f (ConvertTo-XmlText $result.Suite), (ConvertTo-XmlText $result.File), (ConvertTo-XmlText $result.Function), (Format-Seconds $result.DurationMs)))
            $text = ConvertTo-XmlText ($result.Messages -join "`n")
            switch ($result.Status) {
                'failed' { $lines.Add("      <failure message=`"$text`">$text</failure>") }
                'error' { $lines.Add("      <error message=`"$text`">$text</error>") }
                'skipped' { $lines.Add("      <skipped message=`"$text`"/>") }
            }
            $lines.Add('    </testcase>')
        }
        $lines.Add('  </testsuite>')
    }
    $lines.Add('</testsuites>')
    [System.IO.File]::WriteAllLines((Join-Path $ResultsDirectory 'integration.xml'), $lines)
}

function Write-SummaryReport {
    param([Parameter(Mandatory)][object[]]$Results)

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('# Integration test results')
    $lines.Add('')
    $lines.Add('| Session | Passed | Failed | Errors | Skipped |')
    $lines.Add('| --- | --- | --- | --- | --- |')
    foreach ($group in $Results | Group-Object Session) {
        $counts = foreach ($status in 'passed', 'failed', 'error', 'skipped') { @($group.Group | Where-Object Status -eq $status).Count }
        $lines.Add("| $($group.Name) | $($counts -join ' | ') |")
    }
    $failures = @($Results | Where-Object { $FailingStatuses -contains $_.Status })
    if ($failures) {
        $lines.Add('')
        $lines.Add('## Failures')
        foreach ($result in $failures) {
            $lines.Add('')
            $lines.Add("- **$($result.Suite)/$($result.File)::$($result.Function)** ($($result.Status), session $($result.Session))")
            foreach ($message in $result.Messages) { $lines.Add("  - $message") }
        }
    }
    [System.IO.File]::WriteAllLines((Join-Path $ResultsDirectory 'summary.md'), $lines)
}

# --- Main ---

$repoMods = @(Get-ModDirectory -Path $DefaultSourceDirectory | ForEach-Object Name)
$plan = @(New-SessionPlan -Suites @(Get-Suite) -RepoMods $repoMods)
if (-not $plan) { throw 'No tests match the given -Mods, -Session and -Test.' }
if ($List) {
    foreach ($entry in $plan) {
        $thirdParty = if ($entry.ThirdParty) { " + $($entry.ThirdParty -join ', ')" } else { '' }
        Write-Host "[$($entry.Names -join ', ')] $($entry.Mods -join ', ')$thirdParty"
        foreach ($item in $entry.Tests) { Write-Host "  $($item.Suite)/$($item.File.Name)::$($item.Function)" }
    }
    return
}
Remove-Item -LiteralPath $ResultsDirectory -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $ResultsDirectory -Force | Out-Null

$allResults = [System.Collections.Generic.List[object]]::new()
$build = -not $NoBuild
foreach ($entry in $plan) {
    foreach ($result in Invoke-PlannedSession $entry -Build:$build) { $allResults.Add($result) }
    $build = $false
}

Write-JUnitReport $allResults
Write-SummaryReport $allResults
$counts = $allResults | Group-Object Status | ForEach-Object { "$($_.Count) $($_.Name)" }
Write-Host "`n$($allResults.Count) test run(s): $($counts -join ', '). Reports: $ResultsDirectory"
if (@($allResults | Where-Object { $FailingStatuses -contains $_.Status })) { exit 1 }
