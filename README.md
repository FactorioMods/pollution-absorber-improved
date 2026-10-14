# Pollution Absorber: Improved

A fork of [Pollution Absorber](https://mods.factorio.com/mod/pollution-absorber) by yanhanv for Factorio 2.0. An industrial air-filter unit that burns chemical fuel to absorb nearby pollution. It retains the original heat-pipe output.

## Changes

- Cache absorption sample positions instead of creating them every second.
- Combine repeated checks of the same pollution chunk and share fresh readings between overlapping absorbers during each update.
- Remove an unnecessary callback running every tick; rebuild entity references once after loading a save.
- Replace the flat drawing with a detailed industrial air-filter unit: top fan, intake grilles and weathered metal housing. The fan animation uses Factorio's native renderer and adds no Lua tick handler.

Keeps the original 80-tile sampling radius, absorption rate, energy condition and once-per-second schedule. Existing entity, item and recipe names are retained.

## Measured results

Tested on Factorio 2.0.77 using an early-to-mid-game save with 35 absorbers, 33 with energy. Across repeated runs, the median absorption update took 1.56â€“1.58 ms in the original and 0.38â€“0.41 ms in this fork: about 75% less time for that script update.

This reduces the once-per-second script spike; it does not imply a 75% improvement in overall game performance. Pollution totals matched exactly at every save-comparison checkpoint. Another 280 comparisons covered chunk boundaries and low-to-high pollution, with a maximum difference of 1.8e-15 pollution units from floating-point rounding.

Version 1.0.1 was also compared directly with released 1.0.0 on the same isolated save. The timed absorption handler averaged 0.0049–0.0052 ms per tick, versus 0.0070–0.0078 ms for 1.0.0: roughly 30% less total script work. Both still update all absorbers once per second. Pollution totals again matched the original exactly, and 280 overlapping-absorber comparisons passed within floating-point rounding. These timings exclude profiling output and are not a guaranteed in-game timing or UPS increase.

## Installation

Install from the [Factorio Mod Portal](https://mods.factorio.com/mod/pollution-absorber-improved), or download the ZIP from [GitHub Releases](https://github.com/FactorioMods/pollution-absorber-improved/releases) and place it in your Factorio mods directory. Disable the original Pollution Absorber and enable this fork. Existing absorbers are rediscovered when loading the save. Multiplayer clients need the same mod version as the host.

## Credits

Original code and artwork by yanhanv. Fork maintained by johnmart19 under the original MIT license.

[Original source](https://github.com/yanhanv/pollution-absorber) Â· [Report an issue](https://github.com/FactorioMods/pollution-absorber-improved/issues)
