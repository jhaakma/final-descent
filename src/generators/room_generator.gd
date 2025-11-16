class_name RoomGenerator extends Object
## Static helper for room generation - provides caching and scaling utilities

static var cache: Dictionary = {}  # cache_key -> RoomResource

## Scale loot component gold values by stage
static func scale_loot_component(base: LootComponent, stage: int, scaling_factor: float) -> LootComponent:
    if not base:
        push_error("RoomGenerator.scale_loot_component() called with null base LootComponent")
        base = LootComponent.new()

    var scaled := LootComponent.new()
    var multiplier := 1.0 + (scaling_factor * stage)
    scaled.gold_min = int(round(base.gold_min * multiplier))
    scaled.gold_max = int(round(base.gold_max * multiplier))
    scaled.chance_gold_none = base.chance_gold_none
    scaled.loot_table = base.loot_table.duplicate()

    return scaled

## Generate cache key for template + stage combination
static func get_cache_key(template: IRoomTemplate, stage: int) -> String:
    var seed_value := GameState.rng.seed if GameState.rng else 0
    var template_id := template.resource_path if not template.resource_path.is_empty() else str(template.get_instance_id())
    return "%s_%d_%d" % [template_id, stage, seed_value]
