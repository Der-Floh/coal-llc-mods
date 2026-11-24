# Coal LLC test harness

The harness launches Coal LLC with exactly the mods you choose, in a separate profile, and lets a script drive the game through a local HTTP API: cheats, UI actions, GDScript run inside the game, screenshots and logs. The [integration tests](../README.md) are built on it, and it is handy on its own for trying out a change.

It is a dev tool: its mod (`der_floh-test_harness`) lives here, outside `src/`, so neither the build nor GitHub's workflows ever pack or publish it.

## Safety

- **Separate profile.** While the game starts, a marked `override.cfg` next to `Coal LLC.exe` points `user://` at `%APPDATA%\Coal LLC Test`, so saves, logs, mod configs and GML's cache go there instead of `%APPDATA%\Godot\app_userdata\Coal LLC`. The test folder is outside what Steam Cloud syncs. The harness mod deletes `override.cfg` as soon as it loads, and `start` deletes it again in every outcome.
- **Wrong-profile guard.** A harness-launched game that finds itself in any other profile kills itself before it can save, and `start` refuses a game whose `status` reports another `user_data_dir`.
- **GML restarts.** When GML rebuilds `mod-hooks.zip`, the harness restarts the game itself with the same arguments and re-creates `override.cfg` first. The API only opens after GML's hook check, so the process that is about to restart never answers. If `start` fails or is interrupted, it closes the game before removing `override.cfg`.
- **Hook pack per profile.** `start` moves your `mod-hooks.zip` to `run/hook-packs/play.zip` and puts the test pack in its place; `stop` swaps them back.
- **Check at the end.** `start` hashes every file in your real profile; `stop` prints `real_profile_unchanged` and lists any file that changed.
- **No achievements.** The harness sets `SteamWorks.steam_powered = false` before the API opens.
- **Local only.** The API listens on 127.0.0.1 and needs the random per-session token in the `X-Harness-Token` header.

## Usage

Run from the repo root in PowerShell 7 or Windows PowerShell 5.1, with Steam running, and always finish with `stop`:

```powershell
./tests/harness/harness.ps1 start -Mods ingenitus-extra_passives_mod -Compact
./tests/harness/harness.ps1 call new_run @{ profession = 'generalist'; mode = 'PEACEFUL' } -Compact
./tests/harness/harness.ps1 call start_day -Compact
./tests/harness/harness.ps1 eval 'return gvars.CashCount'
./tests/harness/harness.ps1 screenshot mine
./tests/harness/harness.ps1 stop
```

| Script command | What it does |
| --- | --- |
| `start [-Mods <ids>] [-Extra <zips>] [-NoBuild] [-SeedSaves]` | Builds the repo mods and the harness (skipped with `-NoBuild`), copies the chosen zips to `run/mods`, swaps the hook packs, re-enables any mod GML marked inactive in the test profile, launches the game windowed at 1280x720 without sound, and waits for the API. Without `-Mods`, every mod in `src/` is loaded. `-Extra` adds outside zips, such as a third-party mod. `-SeedSaves` first copies your real `v04_*.save` files into the test profile. The wait allows `-StartTimeoutSec` (300) because a new mod set makes GML decompile and rebuild hooks first. |
| `status` | Prints the game state. |
| `call <command> [@{ ... }]` | Sends an API command; arguments go in a hashtable, or as raw JSON with `-Json`. |
| `eval '<gdscript>'` | Runs GDScript inside the game. |
| `screenshot [name]` | Saves `run/screenshots/<name>.png` and prints its path. |
| `log [-Lines N] [-ModLoader]` | Prints the end of the test profile's `godot.log`, or `modloader.log`. |
| `stop` | Quits the game (killing it if it is frozen), removes a leftover `override.cfg`, swaps your hook pack back and runs the profile check. It also repairs an interrupted session. |

`-Compact` prints `status`, `call` and `eval` results on one line without the mod list. The game folder comes from `-GameDirectory`, the `COAL_LLC_GAME_DIR` environment variable, or your Steam libraries.

Scripts can import [`Harness.psm1`](Harness.psm1) instead: `Start-HarnessSession`, `Stop-HarnessSession`, `Invoke-HarnessCommand`, `Get-HarnessLog` and `Clear-HarnessModConfig`.

## API commands

| Command | Arguments (default) | What it does |
| --- | --- | --- |
| `status` | | pid, `user_data_dir`, stage, transitioning, management screen, paused, day, days passed, seconds left, cash, profession, vacuum level, inventory, non-zero passives, the open level-up card, loaded mods |
| `new_run` | `profession` (`generalist`), `level` (`STANDARD`), `mode` (`PEACEFUL`) | Starts a run and waits for the management screen. Peaceful has no quota, so a test run can't be lost. |
| `continue_run` | | Loads the test profile's saved run (see `-SeedSaves`). |
| `start_day` | | Leaves the management screen and waits until the mine has loaded. |
| `end_day` | `skip_summary` (`true`) | Ends the day. Skipping the summary also skips payout, exp, saving and the quota check; without skipping, it stops on the profit summary. |
| `finish_day` | | Waits for the profit summary to finish counting and presses Continue: payout, exp, the quota check and the run save happen as in play, then it waits for the management screen. |
| `set_seconds_left` | `seconds` | Sets the day timer. |
| `give_item` | `path`, `count` (1) | Adds an item resource such as `res://resources/Items/Equipment/Pickaxes/Pickaxe-Shoddy.tres`. |
| `set_cash` | `amount` | Sets the cash. |
| `set_vacuum` | `level` (1) | Sets the vacuum level; during a day it also rebuilds the vacuum, so mod hooks on `generate_vacuum_cleaner` run. |
| `add_passive` | `key`, `amount` (0.05) | Calls `Gvars.passives.apply_effect`; fails if the key doesn't exist or the value didn't change. |
| `open_chooser` | `multiplier` (1) | Opens a level-up card during a day and returns its options. |
| `pick` | `index` (0) | Presses card button 0, 1 or 2, so the whole hook chain runs as for a click. |
| `teleport` | `x`, `y` | Generates the chunks there and moves the player. |
| `tile_effect` | `kind` (`poison`, `burn`, `wet`), `x`, `y`, `damage` (10), `ticks` (10) | Applies a tile effect. |
| `action` | `name`, `mode` (`tap`, `press`, `release`) | Sends an input action, for example `useItem`. |
| `inventory` | `open` (`true`) | Opens or closes the inventory window, which includes the Tab passive list. |
| `screenshot` | `name` | Saves a screenshot. |
| `eval` | `code` | Runs GDScript. |
| `run_test` | `path`, `source`, `function` | Runs one integration test; used by `run-integration.ps1`. |
| `quit` | | Quits the game. |

## eval

The code becomes the body of `func run()`: indent with tabs, `await` works, and whatever you `return` comes back as JSON (values JSON can't hold come back through `var_to_str`). It can use `tree`, `gvars`, `bus`, `game`, `access`, `player()`, `tilemap()`, `gui()` and `mod("<mod-id>")`, which returns that mod's `mod_main` script. Godot gives scripts no compile errors, so a snippet that doesn't compile returns `ok: false` and the reason is in `log`.

```powershell
./tests/harness/harness.ps1 eval 'var lengths = []
for v in tree.get_nodes_in_group(&"ingenitus_extra_passives_vacuum"):
	lengths.append(v.vacuum_length)
return lengths'
```

## Limits

- The day clock counts physics ticks, so `Engine.time_scale` doesn't shorten a day; use `set_seconds_left`.
- Weapons aim at the real mouse, so calling their methods through `eval` works better than simulated input.
- `action` sends an `InputEventAction`, which never reaches `_shortcut_input`, so Esc (`menu`) and similar keys don't react to it. Inject an `InputEventKey` with both `keycode` and `physical_keycode` set through `eval` instead. Timing races, such as resuming from the pause menu, are easier to reproduce by calling the method right after `await tree.process_frame`.
- GML's hook pack only grows. A smaller mod set reuses it without a restart; a newly hooked method rebuilds it and restarts the game once.
- Mods that install hooks or extensions from `_init()` can still cause the early-compile bugs, so test them with the harness too.
- Mod config setters write the test profile's `mod_configs`. Restore what a test changed, or delete that folder, especially after a killed or crashed session.
- A vanilla-sized loot burst (thousands of pickups) or hundreds of level-up cards can freeze or crash the game; `stop` then kills it.
- `new_run` from the management screen removes the old screen's employee icons from their group first: the game builds the new screen before freeing the old one, and its chart would keep drawing the freed icons.

## Files

```
harness.ps1                          command line
Harness.psm1                         session logic, shared with run-integration.ps1
src/der_floh/der_floh-test_harness/  the GML mod: mod_main, server, commands, game_access, eval_runner, test_runner, integration_test, profile_switch, json_value
run/                                 created by the harness, ignored by git: build/, mods/, hook-packs/, screenshots/, results/, session.json, real-profile-fingerprint.json
```

The test profile lives in `%APPDATA%\Coal LLC Test`; delete it whenever you want a clean slate.
