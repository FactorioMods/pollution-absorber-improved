# Pollution Absorber: Improved

A fork of [Pollution Absorber](https://mods.factorio.com/mod/pollution-absorber) by yanhanv for Factorio 2.0. Burns chemical fuel to absorb nearby pollution and connects to heat pipes like a heating tower.

## Changes

- Cache absorption sample positions instead of creating them every second.
- Combine repeated checks of the same pollution chunk.
- Remove an unnecessary callback running every tick; rebuild entity references once after loading a save.

Keeps the original 80-tile sampling radius, absorption rate, energy condition and once-per-second schedule. Existing entity, item and recipe names are retained.

## Measured results

Tested on Factorio 2.0.77 using an early-to-mid-game save with 35 absorbers, 33 with energy. Across repeated runs, the median absorption update took 1.56–1.58 ms in the original and 0.38–0.41 ms in this fork: about 75% less time for that script update.

This reduces the once-per-second script spike; it does not imply a 75% improvement in overall game performance. Pollution totals matched exactly at every save-comparison checkpoint. Another 280 comparisons covered chunk boundaries and low-to-high pollution, with a maximum difference of 1.8e-15 pollution units from floating-point rounding.

## Installation

Install from the [Factorio Mod Portal](https://mods.factorio.com/mod/pollution-absorber-improved), or download the ZIP from [GitHub Releases](https://github.com/FactorioMods/pollution-absorber-improved/releases) and place it in your Factorio mods directory. Disable the original Pollution Absorber and enable this fork. Existing absorbers are rediscovered when loading the save. Multiplayer clients need the same mod version as the host.

## Credits

Original code and artwork by yanhanv. Fork maintained by johnmart19 under the original MIT license.

[Original source](https://github.com/yanhanv/pollution-absorber) · [Report an issue](https://github.com/FactorioMods/pollution-absorber-improved/issues)
