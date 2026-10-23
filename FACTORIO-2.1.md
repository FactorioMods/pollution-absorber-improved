# Factorio 2.1 compatibility and verified tests

Current release: **1.0.5**. Engine/API target: **Factorio 2.1.23**. Updated 2026-10-24.

## API and compatibility changes

- Declare Factorio 2.1 compatibility and use the 2.1 recipe category-list format.
- Version 1.0.5 reuses bound pollution functions during each energized absorber update and reduces Lua iteration overhead. It preserves every pollution read/write and their order, exact clamped arithmetic, the 80-tile radius, rate, fuel condition and 60-tick schedule. Function references remain temporary locals; event registration and persisted data are unchanged.

The earlier API audit used the installed runtime/prototype schemas and reviewed removed members, read-only writes, changed signatures, defines and named table arguments. Indirect calls and optional branches require manual review; this is not a formal proof of every execution path.

## Performance and exact absorption verification (2026-10-24)

Compared 1.0.5 with 1.0.4 inside isolated native Factorio processes, alternating production function bodies on identical native entities and pollution. A copied saved factory had 34 energized absorbers / 358 sampled chunks; an overlap fixture added 64 fueled units, for 98 / 390 chunks.

For the 34-unit saved pollution snapshot, median timing blocks fell from **0.333 to 0.211 ms per update**, a 36.1% median paired reduction across 14 blocks. Separately, 400 individual updates per variant gave a sampled **p95 of 1.047 versus 0.408 ms**. The 98-unit high-pollution fixture improved from **2.299 to 1.254 ms per update**. These are controlled script timings, not a general FPS/UPS improvement or a guaranteed maximum spike.

Direct equality assertions inside Factorio passed **18,700 post-update chunk comparisons** across saved, high, low, sparse and zero pollution, five successive updates and both layouts. Comparison precedes JSON serialization. No spreading of absorption across ticks or algebraic regrouping was used. See [full performance methods, measurements and experiment ledger](PERFORMANCE.md).

## Multiplayer feature verification (2026-10-24)

The exact packaged **1.0.5** runtime archive passed two complete feature rounds with a real connected client, separated by server save/restart/client rejoin, followed by another clean-archive restart/rejoin and continuation. The first round upgrades a copied earlier save. All three rounds saved successfully and no desync, checksum mismatch or nonrecoverable error was detected.

On isolated equally seeded surfaces with pollution diffusion and ageing disabled, a fueled absorber removed approximately **4,027.25 pollution over five seconds**: 4,000 scripted removal plus 27.25 native negative emissions. An unfueled control removed zero. Emptying the burner stopped removal; refueling restored the same five-second result. These checks passed in both full rounds, and the third clean continuation confirmed the same removal after another reload.

The absorber archive was unmodified throughout. The wider fixture used temporary owner-mod setup hooks for Black Market and Even Distribution in rounds 1/2; round 3 restored those clean archives too. This distinction does not weaken the clean-absorber checks, but the first two rounds are not described as an entirely uninstrumented mod set.

## Earlier shared checks

The previous 1.0.4 release passed isolated map creation, copied-save migration, bridge-free save/reload, 3,000-tick behavior checks and an actual localhost multiplayer smoke test. Its quantitative fuel/removal suite also passed on 2026-10-23. Those are historical checks; they are not all independently repeated by every subsequent performance measurement.

## Scope and limits

Tests use the installed base/Space Age/Matt's profile and localhost. The direct callback comparison pauses simulation and restores pollution before each sample; native multiplayer feature tests exercise real tick progression. Timing seed/output overhead is excluded. OS scheduling and the normal game running concurrently affect tails. No promise is made about overall FPS/UPS, every fuel/settings combination, optional overhauls, WAN, multiple simultaneous clients or long-duration stability.

Raw saves, profiles, credentials, logs and private QA hooks are excluded from public source and archives. Release asset hashes are available from GitHub Releases; the earlier 1.0.4 archive remains unchanged.
