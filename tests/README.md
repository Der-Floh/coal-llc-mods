# Integration tests

These tests start Coal LLC with a set of mods and check, inside the running game, that each mod does what its README says: alone, together with every other mod in `src/`, and in the combinations a mod declares. They are local only; no GitHub workflow runs them, because they need the game.

## Requirements

- Coal LLC from Steam with [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) set up, and Steam running. The game folder is found through your Steam libraries; pass `-GameDirectory` or set `COAL_LLC_GAME_DIR` if that fails.
- PowerShell 7 or Windows PowerShell 5.1.
- The game closed. The tests open it windowed at 1280x720, without sound; leave the mouse alone while they run.

Your saves and settings are never touched. The game runs in a separate profile, `%APPDATA%\Coal LLC Test`, with its own hook pack, and every session checks that your real profile stayed unchanged; see [harness/README.md](harness/README.md).

## Running

```powershell
./tests/run-integration.ps1
./tests/run-integration.ps1 -Mods ingenitus-extra_passives_mod
./tests/run-integration.ps1 -Mods der_floh-game_limits_mod -Session solo -Test 'test_out_of_range*'
./tests/run-integration.ps1 -List
```

| Parameter | What it does |
| --- | --- |
| `-Mods <ids>` | Only the suites of these mods. |
| `-Session <names>` | Only these sessions: `solo`, `all`, or a session name from a `suite.json`. |
| `-Test <wildcard>` | Only tests whose function or file name matches. |
| `-List` | Prints the planned sessions and tests without starting the game. |
| `-NoBuild` | Uses the zips of the previous build. |
| `-TimeoutSec` | How long one test may take (default 120) before its session is restarted. |

A full run takes about half an hour. Each session starts the game, runs its tests one at a time and quits; a test that hangs or crashes the game is reported and its session restarted.

Results go to the console and to `tests/harness/run/results/`: `summary.md`, `integration.xml` (JUnit), and the `godot.log` and `modloader.log` of every session with a failure. The exit code is 1 when a test failed.

In VS Code, run the **Integration tests** task.

## Sessions

Every suite runs in two sessions:

- **solo:** its mod alone (plus the harness);
- **all:** all mods in `src/` at once.

A suite's `suite.json` can add more, for mods it has to work with:

```json
{
    "sessions": [
        { "name": "with-tick-upgrade", "mods": ["der_floh-tick_upgrade_mod"], "tests": ["test_passives.gd"] },
        { "name": "with-auto-passive-chooser", "third_party": ["CoalLLC-AutoPassiveChooser"], "tests": ["test_auto_passive_chooser.gd"] }
    ]
}
```

- `mods` are other mods from `src/` loaded together with the suite's mod.
- `third_party` names rows of [`src/ThirdParty/ThirdParty-Mods.csv`](../src/ThirdParty/ThirdParty-Mods.csv); their zips are downloaded by [`fetch-third-party.ps1`](fetch-third-party.ps1) when missing.
- `tests` limits which of the suite's files run there; without it, all of them do.

Sessions that load the same mods are merged, and the largest run first. The tests in `integration/_common/` run first in every session: the game started without script errors, the inventory has all its slots, the settings menu opens and a day can start and end.

## Writing tests

A mod's tests live in `integration/<author>/<mod-id>/`, one `test_<area>.gd` file per feature area. Every `func test_*()` in a file is one test:

```gdscript
extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

const MOD_ID := "ingenitus-extra_passives_mod"


func before_each() -> void:
	if await in_mine():
		mod(MOD_ID).reset_passives()


func test_vacuum_range_lengthens_the_hose() -> void:
	if not await set_vacuum(1):
		return
	gvars.passives.apply_effect("vacuum_range", 0.05)
	var vacuum = tree.get_nodes_in_group(mod(MOD_ID).VACUUM_GROUP)[0]
	expect_eq(vacuum.vacuum_length, 504, "hose length at +5%")
```

The test runs inside the game and may `await`. The base class, [`integration_test.gd`](harness/src/der_floh/der_floh-test_harness/integration_test.gd), provides:

| Group | Members |
| --- | --- |
| Game | `tree`, `gvars`, `bus`, `game`, `player()`, `tilemap()`, `gui()`, `access`, `commands` |
| Mods | `mod(id)` (the mod's `mod_main` script, for its static functions and settings), `has_mod(id)`, `require_mods([ids])` |
| Fixtures | `fresh_run()`, `in_management()`, `in_mine()`, `fresh_mine()`: each returns `false` and records the failure when it can't get there |
| Cheats | `give(item_path, count)`, `set_vacuum(level)`, `press_key(KEY_ESCAPE)`, and the harness commands through `commands.<name>({...})` |
| Waiting | `frames(n)`, `physics_frames(n)` |
| Settings menu | `open_settings()`, `settings_rows(menu, tab)`, `setting_control(menu, tab, label_start)` |
| Restoring | `use_setting(mod_id, setting, value)` (through `set_<setting>`/`get_<setting>`), `use_value(object, property, value)`, `on_cleanup(callable)` |
| Checks | `expect(condition, message)`, `expect_eq`, `expect_near`, `expect_between`, `fail`, `skip(reason)` |
| Hooks | `before_each()`, `after_each()` |

Things to know:

- **Checks don't stop a test.** GDScript has no exceptions, so after a fixture returns `false`, or after `skip()` or `require_mods()`, `return` yourself.
- **Restore what you change.** Change mod settings through `use_setting` or the mod's setters with `on_cleanup`, not by editing config data: several mods cache settings in static variables. After every test the runner also restores config data, unpauses the game, closes open level-up cards and menus and clears poison, fire and wet tiles, and every session starts with default configs.
- **The mine is shared.** Tests in a session reuse the same run and mine, including holes and explosions earlier tests left. Build the terrain a test measures (see `der_floh-game_limits_mod/test_electric.gd`) or start from `fresh_mine()`.
- **Errors fail the test.** A runtime error ends a GDScript function silently, so the runner reads `godot.log` after each test, and any `SCRIPT ERROR` turns it into an error with the message and line.
- **Tests are compiled from the repo** each time they run, with `res://tests/integration/...` as their path, so errors name the file. They can't `preload` other files or use `class_name`, and must not name another mod's classes or files unless that mod is in every session the file runs in; use `has_mod()` and `mod()` instead.
- **Make randomness irrelevant.** Force the state a test needs (card options with `choose_between`, tiles with `change_tile`, chests with `generate_chests`) instead of waiting for luck. The runner seeds the random generator per test, so a test repeats the same way.
- **Keep bursts small.** Thousands of item pickups or level-up cards freeze or crash the game.
- **Keys:** `harness.ps1 call action` sends input actions, which `_shortcut_input` never sees; use `press_key()`. Timing races, such as resuming from the pause menu, are reproduced by calling the method right after `await tree.process_frame`.
- **AutoPassiveChooser** picks level-up cards on its own. Tests that open cards in its sessions set its priorities first (see `ingenitus-extra_passives_mod/test_auto_passive_chooser.gd`).

Try a single test while writing it with `-Mods <id> -Session solo -Test <name>`; add `-NoBuild` when only test files changed.
