# Pollution cleaner performance

Factorio 2.1.23; comparing fork 1.0.4 and 1.0.5. Measurements from 2026-10-24.

## What changed

1.0.5 reuses the bound pollution reader and acquires the writer only when needed. Numeric iteration and a local minimum function reduce Lua overhead. Every pollution call, its order, the clamped arithmetic, fuel condition, radius, rate and 60-tick schedule are unchanged. Function references are local and are never saved.

## Controlled comparison

Baseline and candidate ran alternately in one process on native entities, with identical pollution restored before each update. Seeding and output were outside the timer. Each block averaged 250 updates; two warm-up blocks were excluded. The saved factory had 34 active units sampling 358 chunks. A stress fixture added 64 overlapping units, for 98 units / 390 chunks.

| Workload | 1.0.4 median, ms/update | 1.0.5 median, ms/update |
|---|---:|---:|
| 34 units, saved pollution | 0.333 | 0.211 |
| 34 units, high pollution | 0.946 | 0.474 |
| 34 units, zero pollution | 0.333 | 0.209 |
| 98 units, high pollution | 2.299 | 1.254 |

The candidate was faster in all 14 measured blocks for the 34-unit saved/high/zero cases, and all ten blocks for the 98-unit high-pollution case. Median paired reductions were 36.1% for saved pollution and 48.9% for high pollution in the 34-unit layout.

A separate 400-update sample per variant measured the distribution:

| 34-unit workload | 1.0.4 median / p95, ms | 1.0.5 median / p95, ms |
|---|---:|---:|
| Saved pollution | 0.385 / 1.047 | 0.215 / 0.408 |
| High pollution | 1.003 / 2.201 | 0.532 / 1.014 |

18,700 direct native-double comparisons passed exactly across five pollution cases, five successive updates and both layouts. [Fuel and multiplayer tests](FACTORIO-2.1.md).

## Normal-speed world simulation

A separate copy of New_clean_2 ran for 9,034 ticks at speed 1 with normal fuel use and pollution diffusion. All 34 cleaners stayed active. A temporary timing wrapper observed 150 scheduled updates, each 60 ticks apart, without reseeding pollution or invoking callbacks directly. The observer was headless, with no connected player; the visible normal game was left alone.

Mean callback cost was **0.417 ms**, median **0.415 ms**, p95 **0.582 ms**, p99 **0.631 ms**, and maximum observed **0.695 ms**. Averaged over every game tick, this was **0.0069 ms/tick**. This is a separate workload from the controlled comparison above.

These timings measure cleaner script cost. OS scheduling affects tails; the sample does not bound future spikes or establish an overall FPS/UPS gain.

## Discarded approaches

A branch replacement for the minimum calculation showed no reliable gain. Unconditionally acquiring the writer added clean-chunk work. Lazy writer caching alone was within noise at the saved pollution snapshot; caching the reader as well produced the repeatable improvement above.
