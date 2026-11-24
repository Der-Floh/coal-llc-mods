<#
.SYNOPSIS
Launches Coal LLC with freshly built mods in a separate "Coal LLC Test" profile and drives it through the test harness mod.

.DESCRIPTION
start       Builds the mods, switches to the test profile and test hook pack, launches the game and waits for the harness API.
stop        Quits the game (killing it if frozen), restores your hook pack and reports whether your real profile stayed unchanged.
status      Prints the game state.
call        Sends a harness command, e.g.  harness.ps1 call new_run @{ profession = 'generalist' }
eval        Runs GDScript inside the game, e.g.  harness.ps1 eval 'return gvars.CashCount'
screenshot  Saves a screenshot to run/screenshots/ and prints its path.
log         Prints the end of the test profile's godot.log (modloader.log with -ModLoader).

Your real saves, configs and logs in %APPDATA%\Godot\app_userdata\Coal LLC are never used: a temporary override.cfg points the game at %APPDATA%\Coal LLC Test while it starts. The game folder comes from -GameDirectory, the COAL_LLC_GAME_DIR environment variable, or your Steam libraries.

.EXAMPLE
./tests/harness/harness.ps1 start -Mods ingenitus-extra_passives_mod
./tests/harness/harness.ps1 call open_chooser -Compact
./tests/harness/harness.ps1 stop
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('start', 'stop', 'status', 'call', 'eval', 'screenshot', 'log')]
    [string]$Command,

    [Parameter(Position = 1)]
    [string]$Name,

    [Parameter(Position = 2)]
    [hashtable]$Parameters = @{},

    [string]$Json,
    [string[]]$Mods,
    [string[]]$Extra,
    [switch]$NoBuild,
    [switch]$SeedSaves,
    [switch]$Compact,
    [switch]$ModLoader,
    [int]$Lines = 60,
    [int]$StartTimeoutSec = 300,
    [string]$GameDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'Harness.psm1') -Force

$VerboseStatusFields = 'mods', 'user_data_dir', 'pid'

# Status results list every loaded mod and item; -Compact keeps one line with the parts that change.
function Compress-Status {
    param($Result)

    if ($Result -isnot [psobject] -or -not $Result.PSObject.Properties['inventory']) { return $Result }
    foreach ($field in $VerboseStatusFields) { $Result.PSObject.Properties.Remove($field) }
    $Result.inventory = @($Result.inventory.items | ForEach-Object { "$($_.type) x$($_.count)" })
    $Result
}

function Format-ModList {
    param([Parameter(Mandatory)][object[]]$ModStates)

    @($ModStates | ForEach-Object { "$($_.id)@$($_.version)$(if (-not $_.active) { ' (INACTIVE)' })" }) -join ', '
}

function Write-Result {
    param([Parameter(Mandatory)][object]$Response)

    if ($Compact) {
        if ($Response.PSObject.Properties['result']) { $Response.result = Compress-Status $Response.result }
        $Response | ConvertTo-Json -Depth 20 -Compress
    }
    else {
        $Response | ConvertTo-Json -Depth 20
    }
    if ($Response.PSObject.Properties['ok'] -and -not $Response.ok) { exit 1 }
}

function Write-StartResult {
    param([Parameter(Mandatory)][object]$Result)

    if ($Compact) { "ok=$($Result.ok) stage=$($Result.status.stage) mods: $(Format-ModList $Result.status.mods)" }
    else { $Result | ConvertTo-Json -Depth 20 }
}

function ConvertTo-RequestBody {
    param([hashtable]$Values)

    if ($Json) { return $Json }
    $Values | ConvertTo-Json -Depth 10 -Compress
}

switch ($Command) {
    'start' { Write-StartResult (Start-HarnessSession -Mods $Mods -Extra $Extra -NoBuild:$NoBuild -SeedSaves:$SeedSaves -GameDirectory $GameDirectory -StartTimeoutSec $StartTimeoutSec) }
    'stop' { Write-Result (Stop-HarnessSession -GameDirectory $GameDirectory) }
    'status' { Write-Result (Invoke-HarnessCommand -Name 'status') }
    'call' { Write-Result (Invoke-HarnessCommand -Name $Name -Json (ConvertTo-RequestBody $Parameters)) }
    'eval' { Write-Result (Invoke-HarnessCommand -Name 'eval' -Arguments @{ code = $Name }) }
    'screenshot' {
        $fileName = if ($Name) { $Name } else { 'screenshot' }
        Write-Result (Invoke-HarnessCommand -Name 'screenshot' -Arguments @{ name = $fileName })
    }
    'log' { Get-HarnessLog -Lines $Lines -ModLoader:$ModLoader }
}
