# Cleaner update performance — 1.0.5

Factorio **2.1.23**, compared with release **1.0.4**, 2026-10-24.

Version 1.0.5 reduces repeated lookups of bound `LuaSurface` functions. Each energized absorber acquires its pollution reader once; it acquires the writer only when pollution is present. Numeric iteration over the dense cached sample array and a local `math.min` reduce Lua overhead. No engine read or write is removed, combined, deferred or reordered. The existing shared chunk cache still reads fresh pollution on each update.

The radius, rate, 30% center / 70% sampling allocation, sequential clamped subtraction, fuel/energy condition, native emissions, and 60-tick schedule are unchanged. All units still update together; the optimization does not distribute absorption across ticks. Event registration and persisted state are unchanged. Function references are temporary locals, never saved in `storage`.

## Measurements

The representative copied save contains **34 energized absorbers** sampling **358 distinct chunks**. A separate stress fixture adds 64 fueled, overlapping absorbers, for **98 active units / 390 chunks**. Tests use the installed mod profile in isolated host processes. The player's normal game remains running.

Baseline and candidate function bodies run alternately inside the same process on the same native entities, with identical pollution restored before every measured update. Timing uses `helpers.create_profiler`; seeding and output are outside the measured interval. Natural pollution means a snapshot of the copied save, with simulation paused during direct callback comparison. Other cases seed high, near-depletion, sparse or zero pollution. This isolates script cost; it is not an end-to-end simulation benchmark.

Each timing block averages 250 callback invocations. Orders rotate and reverse between blocks. After excluding two warm-up blocks, the normal-save confirmation has 14 balanced blocks; the stress confirmation has ten.

| Workload | 1.0.4 median block, ms/update | 1.0.5 median block, ms/update |
|---|---:|---:|
| 34 units, saved pollution snapshot | 0.333 | 0.211 |
| 34 units, high pollution | 0.946 | 0.474 |
| 34 units, zero pollution | 0.333 | 0.209 |
| 98 units, high pollution | 2.299 | 1.254 |
| 98 units, zero pollution | 0.581 | 0.482 |

Median paired reductions were **36.1%** for the saved pollution snapshot and **48.9%** for the 34-unit high-pollution case; the candidate was faster in all 14 measured blocks in both cases. The 98-unit high-pollution case improved **45.4%**, faster in all ten measured blocks. These paired statistics can differ from the ratio of the two marginal medians in the table.

Separately, 400 individually timed updates per variant and pollution case measured the distribution rather than only block averages:

| 34-unit workload | 1.0.4 median / p95, ms | 1.0.5 median / p95, ms |
|---|---:|---:|
| Saved pollution snapshot | 0.385 / 1.047 | 0.215 / 0.408 |
| High pollution | 1.003 / 2.201 | 0.532 / 1.014 |

OS scheduling and concurrent applications affect tails. These measurements do not guarantee a maximum spike or imply an overall FPS/UPS gain. They are not a before/after comparison with a debug-overlay screenshot.

## Exact behavior checks

Inside Factorio, direct double equality assertions compared every tracked chunk after each of five successive updates for saved, high, low, sparse and zero pollution, in both layouts: **18,700 post-update chunk comparisons passed exactly**. Comparisons happen before JSON serialization. Native entities and the production function bodies are used; this is not merely a separate arithmetic model. Actual fuel, multiplayer, upgrade and reload checks are described in [the compatibility guide](FACTORIO-2.1.md).

## Experiment ledger

| Attempt | Decision |
|---|---|
| Replace repeated `math.min` with branches | Discarded: equivalent outputs, no demonstrated gain in the initial separate-process comparison. |
| Acquire the writer unconditionally | Discarded: faster on polluted chunks, extra work in clean chunks. |
| Acquire writer lazily | Useful on polluted chunks; insufficient alone at the saved pollution snapshot. |
| Numeric sample iteration / local minimum | Retained with caching: separate high-pollution comparison improved the median paired timing by 7.1%, faster in 12/14 blocks. |
| Lazy writer plus numeric iteration | Faster on high/low/sparse fixtures; saved-snapshot confirmation alone was within noise. Superseded by the reader-cache candidate. |
| Cache the reader as well | Retained: repeatable improvement in saved, high and zero-pollution workloads, with exact native results. |

Raw saves, profiles, player identifiers, credentials and private QA hooks are excluded from the repository and release archive.
