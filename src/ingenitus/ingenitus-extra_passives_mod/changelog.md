# Changelog

## [1.0.0] – 2026-09-25

- Initial release: ten new level-up passives, offered only while you own an item they apply to
  (or a vacuum) and removed from the offers once capped.

| Passive | Per pick | Offered with | Effect |
| --- | --- | --- | --- |
| Gun Fire Rate | +5% | pistol, shotgun, rifle, minigun | divides the gun cooldown, never below 0.05 s (cap +1300%) |
| Extra Projectiles | +10% | guns | extra bullets per shot; fractions add up across shots |
| Bullet Pierce | +10% | guns | bullets pass through extra breakable blocks; solid tiles still stop them |
| Axe Spin-Up Speed | +5% | axe, battleaxe | the whirl reaches full spin (and stops) faster |
| Vacuum Range | +5% | a vacuum | longer hose |
| Vacuum Suction | +5% | a vacuum | wider grab area at the nozzle |
| Drill Speed | +5% | drill | drills dig faster |
| Earthquake Damage | +5% | earthquake inducer | more damage |
| Earthquake Radius | +5% | earthquake inducer | bigger radius (cap +380%) |
| Bomb Radius | +5% | bombs, nuke | bigger blasts (cap +1100%) |

- Every bomb and earthquake blast is limited to 48 tiles (the loaded area around the player), so
  small bombs get the full benefit while the nuke (40) grows at most to 48.
- Bomb Radius gets a dial-back slider in the passive bonuses panel (Tab) once earned; the nuke
  narrator line still only plays for the nuke.
- Assassins can now be offered Wet Damage (they field water-throwing elementalists).
- Levels are saved in the run save. `Gvars.passives.get(name)` returns them, so
  NanobotZ-AutoPassiveChooser can prioritise and limit them; works alongside tick_upgrade_mod.
- Config: `enabled` (default: true)
