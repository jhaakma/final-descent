# Room Generation System

## Overview

Procedural room generation system following the EnemyGenerator pattern. Rooms are generated from templates using "plain english tags" with automatic stage-based balancing.

## Architecture

### IRoomTemplate (Interface)
Base interface defining the contract for all room templates:
- `get_title() -> String` - Returns computed/selected title
- `get_description() -> String` - Returns computed/selected description
- `generate_room(stage: int) -> RoomResource` - Creates final room with stage scaling

### Specific Template Subclasses
Each room type has its own template class extending IRoomTemplate:
- **CombatRoomTemplate** - Uses EnemyGenerator, title/description variants
- **ChestRoomTemplate** - LootComponent with gold scaling, chance_empty
- **RestRoomTemplate** - Base heal amount with scaling, message variants
- **ShrineRoomTemplate** - Costs, blessings, loot, curse mechanics
- **ShopRoomTemplate** - LootComponent for inventory with gold scaling
- **BlacksmithRoomTemplate** - Costs, modifiers, cost scaling
- **MimicRoomTemplate** - Mimic EnemyGenerator

### RoomGenerator (Static Helper)
Provides shared utilities for all templates:
- `cache: Dictionary` - Caches generated rooms by template + stage
- `scale_loot_component(base, stage, scaling)` - Scales gold values
- `get_cache_key(template, stage)` - Generates cache keys

## Design Fixes

### Room Type Consolidation
- **Remove**: StageTags enum (redundant)
- **Keep**: RoomType enum as single source of truth
- **Update**: StageTemplateResource to use RoomType instead of StageTags
- **Update**: StageGenerator constraint logic to match by RoomType

### Simplified Architecture
- **Remove**: Generic RoomTemplate with complex config exports
- **Use**: Specific template subclasses (CombatRoomTemplate, ChestRoomTemplate, etc.)
- **Benefits**: Each template is self-contained, no config resource indirection
- IRoomTemplate.generate_room() is the PRIMARY method - subclasses implement directly
- RoomGenerator provides OPTIONAL static helpers for scaling/caching

## Implementation Checklist

### Phase 1: Core Infrastructure
- [ ] Create `src/rooms/templates/` directory
- [ ] Create `IRoomTemplate.gd` base interface
- [ ] Create `RoomType.gd` enum (extract from RoomTemplate)
- [ ] Remove `StageTags.gd` enum
- [ ] Update `StageTemplateResource` to use `Array[RoomType]` instead of `Array[StageTags.Tag]`
- [ ] Update `RoomResource` to use `room_type: RoomType` instead of `tags: Array[StageTags.Tag]`
- [ ] Update `StageGenerator` constraint logic to match by RoomType

### Phase 2: Specific Template Classes
- [x] Create `IRoomTemplate.gd` base interface
- [x] Create `CombatRoomTemplate.gd`
- [x] Create `ChestRoomTemplate.gd`
- [x] Create `RestRoomTemplate.gd`
- [x] Create `ShrineRoomTemplate.gd`
- [x] Create `ShopRoomTemplate.gd`
- [x] Create `BlacksmithRoomTemplate.gd`
- [x] Create `MimicRoomTemplate.gd`

### Phase 3: RoomGenerator Helper
- [x] Create `RoomGenerator.gd` with static cache and utilities
- [x] Implement `scale_loot_component(base, stage, scaling)` helper
- [x] Implement `get_cache_key(template, stage)` helper

### Phase 4: Template Resources
- [ ] Create `data/rooms/templates/` directory
- [ ] Create combat room template .tres (goblin encounter)
- [ ] Create chest room template .tres
- [ ] Create rest room template .tres
- [ ] Create shrine room template .tres

### Phase 5: StageGenerator Integration
- [ ] Update `StageGenerator.generate()` signature to accept `Array[IRoomTemplate]`
- [ ] Update constraint matching to use RoomType
- [ ] Call `template.generate_room(floor)` instead of using RoomResource directly
- [ ] Update tests to use IRoomTemplate
- [ ] Update `StageIntegrationTest` to create template instances

### Phase 6: Testing
- [ ] Create `RoomGeneratorTest.gd`
- [ ] Test combat room generation with stage scaling
- [ ] Test chest room generation with loot scaling
- [ ] Test rest room generation with heal scaling
- [ ] Test shrine room generation with cost scaling
- [ ] Test caching behavior
- [ ] Update `StageGeneratorTest` to verify template usage
- [ ] Run full test suite

### Phase 7: Documentation & Cleanup
- [ ] Update `StageGenerationPlan.md` with RoomType changes
- [ ] Document room template creation workflow
- [ ] Add example custom template implementations
- [ ] Create git commit

## Key Patterns

### Stage Scaling Formula
```gdscript
var stage_multiplier := 1.0 + (scaling_per_stage * stage)
var scaled_value := int(round(base_value * stage_multiplier))
```

### Caching Strategy
```gdscript
var cache_key := RoomGenerator.get_cache_key(self, stage)
if RoomGenerator.cache.has(cache_key):
    return RoomGenerator.cache[cache_key]
# ... generate room ...
RoomGenerator.cache[cache_key] = room
```

### Template Usage
```gdscript
# Combat template with variants
var template := CombatRoomTemplate.new()
template.room_type = RoomType.Type.COMBAT
template.title_variants = ["Goblin Ambush", "Enemy Patrol"]
template.enemy_generator = preload("res://data/enemies/generators/goblin_gen.tres")

# Custom computed template
class_name DynamicBossRoom extends IRoomTemplate
func get_title() -> String:
    return "Boss: %s" % _get_boss_name_for_stage()
func generate_room(stage: int) -> RoomResource:
    # Custom logic here
```

## Migration Notes

- Existing RoomResource subclasses remain unchanged initially
- Templates generate RoomResource instances (not replace them)
- StageGenerator uses templates, legacy room selection can coexist during migration
- Once stable, remove legacy weighted selection from RoomScreen
