# Stage Generation Plan

> WIP design document for implementing multi-floor stage composition with themed progression, constrained room selection, boss integration, and future quest hooks.

## Goals
1. Each Stage is a fixed-length sequence of rooms ending in a boss encounter.
2. Difficulty, enemy composition, loot quality, and encounter patterns scale with stage number.
3. Each Stage has an associated Theme that influences available enemies, room weights, visuals, ambient effects, and loot biases.
4. Room selection is partially random but must satisfy declarative constraints (e.g. “at least one CHEST room”).
5. Design is flexible and extensible: future systems (QuestManager, Story beats, Dynamic modifiers) can inject or replace rooms without rewriting the generator.
6. Deterministic generation possible via seed for debugging and reproducibility.

## High-Level Architecture (Simplified MVP)

| Component | Responsibility |
|-----------|----------------|
| `StageManager` | Tracks current stage + floor index; delivers current planned room; emits stage/boss signals. |
| `StageTemplateResource` | Minimal rules: length, mandatory/disallowed tags, optional tag weights, repeat caps, boss + pre-boss metadata. |
| `StageInstance` | Runtime plan (array of room selections + boss), seed, integrity flag. |
| `StageGenerator` | Builds a `StageInstance` from template + seed using greedy mandatory satisfaction then weighted fill. |
| `StageTag` enum | Canonical tag set used by `RoomResource` to avoid string matching. |
| (Deferred) Theme | Later will bias enemy/loot and add visuals; not needed for MVP. |
| (Deferred) Difficulty Profile | Fold simple multipliers directly into template until needed externally. |
| (Deferred) Injection Rules | Single future hook; not part of MVP implementation. |
| Boss selection | Simple callable or mapping inside template returning a boss `RoomResource`. |

## Data Model Draft

### Room Tagging (Phase 1)
Add to `RoomResource` (MVP fields only):
```gdscript
@export var tags: Array[int] = []              # values from StageTag enum
@export var rarity: float = 1.0                # selection weight modifier
@export var exclusivity_group: StringName = "" # only one room with same group per stage
```

We intentionally defer `min_stage/max_stage` and theme affinities; existing `min_floor/max_floor` still govern progression if needed.

Canonical enum `StageTag` (ints):
```
COMBAT, ELITE, CHEST, REST, EVENT, SHOP, QUEST,
PRE_BOSS, BOSS, TREASURE, STORY, PUZZLE
```

### (Deferred) StageThemeResource
Not required for Phase 1. When introduced it will carry enemy/loot pools and presentation data. Omitted to reduce initial complexity.

### StageTemplateResource (Phase 1)
```gdscript
@export var floors: int = 10                              # total rooms incl boss
@export var mandatory_room_tags: Array[int] = []          # StageTag values; each must appear ≥1
@export var optional_tag_weights: Dictionary = {}         # StageTag int -> float weight
@export var max_repeats_per_tag: Dictionary = {}          # StageTag int -> int cap
@export var disallowed_tags: Array[int] = []              # tags excluded entirely
@export var boss_selector: Callable                       # () -> RoomResource
@export var pre_boss_room_tag: int = -1                   # StageTag or -1 for none
```
Deferred: theme reference, difficulty profile, injection rules.

### StageInstance (Phase 1 runtime struct / Resource)
```gdscript
var template: StageTemplateResource
var seed: int
var planned_rooms: Array[RoomPlan]   # ordered sequence; last is boss
var integrity_ok: bool = true
```

`RoomPlan` fields:
```gdscript
var room_resource: RoomResource
var floor_index: int          # 0-based
var tags: Array[StringName]
var injected_by: StringName = &""  # e.g. &"QUEST:HermitMarbles"
```

## Generation Algorithm (Simplified MVP)
1. Collect candidate rooms (filter by disallowed tags and basic availability rules already in RoomResource).
2. Build tag -> room list map once.
3. Satisfy each mandatory tag: pick one weighted by `rarity` (skip if pool empty -> fallback tag, set `integrity_ok = false`).
4. Reserve final non-boss slot for `pre_boss_room_tag` if defined.
5. Fill remaining slots (excluding reserved and boss) using weighted random:
  - Base weight = room.rarity.
  - Apply anti-repeat penalty if room appeared in recent history (reuse existing RoomScreen logic via shared history array).
  - Enforce `max_repeats_per_tag` and `exclusivity_group` uniqueness.
6. Select boss via `boss_selector()`.
7. Validation: mandatory present, boss last, repeat caps respected.
8. Return `StageInstance`.

Target distribution math, multi-phase injections, and theme filtering are deferred until after MVP stability.

### Anti-Repeat & History Logic
Use existing `recent_room_history` (RoomScreen) as input; apply a simple multiplier (e.g. 0.3) to weight for recently used rooms.

### Failure Handling
If mandatory tag pool empty: fallback to a related tag (CHEST -> TREASURE) or any available non-disallowed room; mark `integrity_ok = false` and `push_error()`.

## Difficulty Scaling (Deferred)
For MVP, scaling can be a simple formula inside enemy/loot generators using `StageManager.get_current_stage()`. External profile resources deferred until clear balancing needs.

## Theme Integration (Deferred)
Theme only influences enemy/loot pools and visuals later. First implementation ignores theme; all rooms eligible unless disallowed by template.

## Boss Integration (Phase 1)
`boss_selector: Callable` returning a `RoomResource` (already tagged BOSS). Boss scaling handled directly in enemy creation using stage number. Pre-boss slot reserved if `pre_boss_room_tag` provided.

## Quest / Story Injection Hooks (Deferred)
Single future hook planned after mandatory selection; full multi-phase system postponed until a concrete quest requires it.

## Persistence Strategy (MVP)
Persist only: `template_id`, `seed`, `current_floor_index`. Rebuild plan deterministically from seed on load. Optionally store full room IDs in a debug flag mode for validation. Helpers:
```gdscript
func get_current_room_plan() -> RoomPlan
func advance_room_plan() -> void
```
`RoomScreen._generate_room()` will consume planned order once stable; retain legacy fallback until validated.

## Testing Strategy (Phase 1 scope)
Initial tests:
1. Mandatory tag satisfaction (e.g. CHEST).
2. Boss last position.
3. Max repeat cap enforced.
4. Determinism (same seed → identical plan).
5. Fallback sets `integrity_ok = false` when mandatory pool empty.

Edge cases (Phase 1):
* `floors = 1` (only boss).
* No optional rooms available.

## Implementation Phases (Revised)
1. Room tagging fields + `StageTag` enum constants.
2. Minimal `StageTemplateResource` (no theme/injection yet).
3. Basic `StageGenerator` (mandatory + fill + pre-boss + boss).
4. Integrate with `StageManager` + `RoomScreen` (feature flag toggle).
5. Add simple boss scaling & pre-boss reservation.
6. Persistence (seed + template id + floor index).
7. Initial tests.
8. Introduce Theme (enemy/loot bias).
9. Add injection hook (quests/story).
10. Extended difficulty profiles & visual theming.

## API Sketch Summary (Phase 1)
```gdscript
StageGenerator.generate(stage_number: int, seed: int, template: StageTemplateResource) -> StageInstance
StageManager.build_stage_instance(template: StageTemplateResource, seed: int)
StageManager.get_current_room_plan() -> RoomPlan
StageManager.advance_room_plan() -> void
```

## Open Questions / Future Enhancements
* Variable stage lengths per template vs global default.
* Dynamic modifiers (e.g., Stage with global DOT hazard).
* Stage skip / practice mode.
* Mid-stage mini-boss or elite fork branching.
* Adaptive weighting based on player build (e.g., ensure potion rooms if low on healing).

## Progress Checklist
Phase 1 focus only; later items deferred.
```text
[x] 1. Add Room tagging fields and StageTag enum
[x] 2. Minimal StageTemplateResource (MVP fields)
[x] 3. Basic StageGenerator (mandatory + weighted fill + boss)
[x] 4. StageInstance runtime struct with plan array
[x] 5. Pre-boss reservation & boss selection via callable
[x] 6. Initial tests (mandatory, boss last, repeats, determinism, fallback) - ALL PASSING
[x] 7. Integrate StageInstance consumption in StageManager/RoomScreen (flag) - COMPLETED
[x] 8. Integration tests (manager advance, room consumption) - ALL PASSING
[x] 9. Remove exclusivity_group from RoomResource (defer feature) - COMPLETED
[ ] 10. Implement RoomTemplate + RoomGenerator (align with EnemyGenerator pattern)
[ ] 11. Integrate RoomGenerator into StageGenerator
[ ] 12. Add @export stages array to RoomScreen, initialize StageManager on run start
[ ] 13. Remove legacy room selection from RoomScreen (weighted random, history)
[ ] 14. Refactor RoomScreen: extract non-UI logic into RoomController/RunController
--- Deferred ---
[ ] 15. Persistence (seed/template id/floor index)
[ ] 16. Exclusivity groups for rooms
[ ] 17. Theme integration
[ ] 18. Quest injection hook
[ ] 19. Difficulty profile resources
[ ] 20. Extended visual theming
[ ] 21. Stage rewards table
[ ] 22. Seed debug UI
[ ] 23. Balancing pass on weights & repeats
```

## Initial Action Plan
Immediate next steps recommended: (1) tagging fields, (2) resource skeletons, (3) basic generator. After verification via small tests, proceed to incremental complexity.

## Room Template/Generator System (Phase 2)

Following the pattern established by `EnemyGenerator`, rooms should be generated from templates rather than being static resources. This enables:
- Procedural room variations (different loot tables, enemy counts, modifiers)
- Stage-based scaling (difficulty increases with stage progression)
- Dynamic content injection (quests, events, story beats)
- Reduced manual resource creation overhead

### RoomTemplate Resource
```gdscript
class_name RoomTemplate extends Resource

@export var room_type: StringName  # "combat", "chest", "rest", "shop", "boss"
@export var tags: Array[StageTags.Tag] = []
@export var title_variants: Array[String] = []
@export var description_variants: Array[String] = []
@export var rarity: float = 1.0
@export var min_floor: int = 0
@export var max_floor: int = -1

# Type-specific configuration (use typed resources per room type)
@export var combat_config: CombatRoomConfig
@export var chest_config: ChestRoomConfig
@export var shop_config: ShopRoomConfig
# etc.
```

### RoomGenerator
```gdscript
class_name RoomGenerator extends RefCounted

static var _room_cache: Dictionary = {}  # Cache generated rooms by template+seed

static func generate(template: RoomTemplate, stage: int, seed: int) -> RoomResource:
    # Check cache first
    var cache_key := _make_cache_key(template, stage, seed)
    if _room_cache.has(cache_key):
        return _room_cache[cache_key]

    # Generate based on room type
    var room: RoomResource
    match template.room_type:
        &"combat":
            room = _generate_combat_room(template, stage, seed)
        &"chest":
            room = _generate_chest_room(template, stage, seed)
        # etc.

    # Apply common properties
    room.tags = template.tags
    room.rarity = template.rarity
    room.title = _pick_variant(template.title_variants, seed)
    room.description = _pick_variant(template.description_variants, seed)

    _room_cache[cache_key] = room
    return room
```

### Integration Points
1. **StageGenerator**: Accept `Array[RoomTemplate]` instead of `Array[RoomResource]`, call `RoomGenerator.generate()` for each selection
2. **StageManager**: Store template references in persistence, regenerate rooms on load
3. **RoomScreen**: Load `@export var room_templates: Array[RoomTemplate]` instead of scanning directory

### Migration Strategy
1. Create `RoomTemplate` base class and type-specific config resources
2. Implement `RoomGenerator` with basic combat/chest/rest room generation
3. Update `StageGenerator.generate()` signature to accept templates
4. Create `.tres` files for existing rooms as templates
5. Update tests to use templates
6. Remove old static room resources once validated

## RoomScreen Refactoring (Phase 3)

`RoomScreen` currently handles too many responsibilities:
- UI rendering and updates
- Room loading and selection logic
- Combat state management
- Inventory interactions
- Status effect display
- Log management
- Inline content management

### Proposed Architecture

**RoomScreen (UI only)**
- Rendering room UI (title, description, actions)
- Displaying stats, inventory, buffs
- Forwarding user input to controller
- Updating displays when notified

**RunController (game logic)**
- Managing run lifecycle (start, progression, end)
- Stage initialization and advancement
- Room generation and selection
- Combat state coordination
- Save/load orchestration

**RoomStateManager (current room state)**
- Current room reference
- Cleared status
- Available actions
- Inline content management

### Implementation Plan
1. Create `RunController` class extending `RefCounted`
2. Move stage initialization logic from `RoomScreen._ready()` to `RunController.start_run()`
3. Move room generation logic to `RunController.generate_next_room()`
4. Move combat state management to `RunController`
5. Update `RoomScreen` to hold `RunController` reference and delegate logic
6. Connect `UIEvents` signals to `RunController` instead of `RoomScreen`
7. Move `starting_rooms` and room template arrays to `RunController`
8. Clean up `RoomScreen` static variables (`recent_room_history`)

### Benefits
- Testable game logic independent of UI
- Clearer separation of concerns
- Easier to add features (multiplayer, replay, simulation)
- UI can be swapped/redesigned without touching logic
- Follows existing pattern (CombatStateManager, StatusEffectManager)

---
**Status:** Document added; no code changes yet. Begin with Phase 1 for smallest surface area + low risk.
