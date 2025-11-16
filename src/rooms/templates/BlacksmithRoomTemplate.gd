class_name BlacksmithRoomTemplate extends IRoomTemplate
## Template for blacksmith room generation

@export var title_variants: Array[String] = ["Blacksmith"]
@export var description_variants: Array[String] = ["A blacksmith tends to the forge."]
@export_range(0.0, 10.0) var base_repair_cost_per_condition: float = 2.0
@export_range(0.0, 10.0) var base_upgrade_cost_multiplier: float = 1.5
@export_range(0.0, 10.0) var cost_scaling_per_stage: float = 0.1
@export var available_modifiers: Array[EquipmentModifier] = []

func get_room_type() -> RoomType.Type:
    return RoomType.Type.BLACKSMITH

func get_title() -> String:
    if title_variants.is_empty():
        return "Blacksmith"
    return title_variants[GameState.rng.randi_range(0, title_variants.size() - 1)]

func get_description() -> String:
    if description_variants.is_empty():
        return "A blacksmith tends to the forge."
    return description_variants[GameState.rng.randi_range(0, description_variants.size() - 1)]

func generate_room(stage: int) -> RoomResource:
    var cache_key := RoomGenerator.get_cache_key(self, stage)
    if RoomGenerator.cache.has(cache_key):
        return RoomGenerator.cache[cache_key] as BlacksmithRoomResource

    var room := BlacksmithRoomResource.new()
    var cost_multiplier := 1.0 + (cost_scaling_per_stage * stage)
    room.repair_cost_per_condition = int(round(base_repair_cost_per_condition * cost_multiplier))
    room.upgrade_cost_multiplier = base_upgrade_cost_multiplier * cost_multiplier
    room.available_modifiers = available_modifiers.duplicate()

    room.title = get_title()
    room.description = get_description()
    apply_common_properties(room)

    RoomGenerator.cache[cache_key] = room
    return room
