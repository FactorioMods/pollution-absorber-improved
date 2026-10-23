# Factorio 2.1 notes

Tested with **Factorio 2.1.23**. Current fork version: **1.0.5**.

## Changes

- Updated recipe categories for 2.1.
- Cached pollution functions and reduced Lua loop overhead in 1.0.5; rate, timing, fuel condition and write order are unchanged.

## Tests

- 18,700 exact native-double chunk comparisons across five pollution cases and two layouts.
- Fueled/refueled removal stayed about 4,027.25 pollution per five seconds; depleted and unfueled removal was zero.
- Three connected-client rounds passed with save/restart/rejoin.

Controlled 34-unit comparison: median update 0.333 → 0.211 ms; sampled p95 1.047 → 0.408 ms. These are script timings, not an overall FPS/UPS gain. See PERFORMANCE.md for methods.

Tests used private copies of saves and local host/client sessions. Raw player data and test hooks are not shipped.
