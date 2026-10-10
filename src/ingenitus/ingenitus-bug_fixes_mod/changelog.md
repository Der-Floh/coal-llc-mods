# Changelog

## [1.1.1] – 2026-09-26

- **Loot cap during bursts** no longer changes ordinary play. 1.1.0 kept the game's live-loot
  counter current within a frame, but vanilla also uses that counter for its 200-item thresholds
  (bigger drop bundles, pile merging), so those started engaging mid-frame long before the cap was
  reached. The fix now keeps its own count of this frame's new pickups and uses it only for the cap
  decision; the game's counter is left alone. Bursts are still capped (3000 drops -> 402 pickups at
  cap 400) with no loot lost.

## [1.1.0] – 2026-09-25

- **Chest upgrade-card multiplier** – every chest's passive-upgrade card shared one pickup effect
  (`PASSIVE_UPGRADE.duplicate()` is shallow), so a card's multiplier was whatever the most recently
  rolled chest set: a level-1 card read x4 after a level-4 chest rolled, a level-4 card dropped to
  x1 after a level-1 chest. Each card now keeps its own chest's multiplier.
- **AOE miner gap** – AOE employees' strikes skipped every tile in the row and column of their
  target (`get_radius` used `and` where `or` was meant): range 1 hit 4 tiles instead of 8, range 2
  hit 16 instead of 24. They now hit the full square (miners and flying miners).
- No longer hooks `Gvars.gd`: together with `der_floh-ore_value_mod`'s script extension of the same
  script, the first launch after installing (when GML builds its hook pack) failed to load player
  skins and settings. The quota is now corrected right after a day starts and on the management
  screen's "Upcoming Coal Quota" line; damaged saves are restored from their backups when the mod
  starts, before the game reads them.

## [1.0.0] – 2026-09-25

- Initial release. Adds a **Bug Fixes** tab; every fix can be switched off on its own.
- **Coal quota overflow** – from day 62 (32 days past the quota table) the quota went negative
  (about -1.1e29) because `increaseQuota` grows it with an integer power. It now keeps growing
  x4 per day in floating point; earlier days are unchanged.
- **Save restore** – a missing or corrupt primary save loaded defaults (or nothing) even though an
  intact backup existed, and the next save then overwrote the backup too. The backup is now put
  back before loading (globals, records, hard-modifier records).
- **Stuck pause** – resuming with Esc could leave the game paused with no menu (the pause menu
  re-paused the tree in the same frame). The menu stops processing before it resumes.
- **Negative cash** – buying the maximum affordable employees could leave cash slightly below zero
  (float rounding, up to -65536 at large balances). Negative results are clamped to zero;
  fractional purchases are unchanged.
- **Loot duplication** – a pickup that had just been merged or fully collected could be merged or
  collected again in the same frame (8 coal could become 11). Spent pickups are now skipped.
- **Loot cap during bursts** – the world loot cap never engaged when thousands of drops happen in
  one frame (nukes, earthquakes): 3000 drops made 3000 pickups. Drops past the cap are now bundled
  for the rest of the frame (about 400 pickups), with no loot lost.
- **Explosion edges** – bombs and earthquakes never reached the bottom row and right column of
  their circle. The skipped tiles are now hit.
- **x0 employee boxes** – float dust left after promotions showed "x0" boxes with a sell button.
  Counts that display as zero are hidden like an exact zero.
