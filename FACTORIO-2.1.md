# Factorio 2.1 update

- Declare Factorio 2.1 compatibility.
- Migrate the absorber recipe to the 2.1 categories format.

Validated with Factorio 2.1.23 in an isolated full-mod environment: fresh map creation, copied-save upgrade and 1,800 simulation ticks. Combined feature checks covered production by all five advanced assembler tiers, science chest refill, nine loader variants, underground-belt build events and disabled robot charging. These checks do not establish full multiplayer or optional-overhaul compatibility.

Additional checks passed: a migrated save reloaded for 1,800 ticks after removing the Black Market bridge; Even Distribution replaced real furnace fuel; Max Rate Calculator processed an assembler selection; Black Market constructed its main and item-selection windows. The furnace legacy option generated the converted smelting recipes with category lists. Interaction checks used temporary private test hooks, excluded from the distributed ZIPs.
