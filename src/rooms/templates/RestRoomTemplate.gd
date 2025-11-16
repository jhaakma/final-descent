class_name RestRoomTemplate extends IRoomTemplate
## Template for rest room generation

@export var title_variants: Array[String] = ["Rest Area"]
@export var description_variants: Array[String] = ["A safe place to rest."]
@export var base_heal_amount: int = 4
@export var heal_scaling_per_stage: float = 0.15
@export var rest_message_variants: Array[String] = []

func get_room_type() -> RoomType.Type:
    return RoomType.Type.REST

func get_title() -> String:
    if title_variants.is_empty():
        return "Rest Area"
    return title_variants[GameState.rng.randi_range(0, title_variants.size() - 1)]

func get_description() -> String:
    if description_variants.is_empty():
        return "A safe place to rest."
    return description_variants[GameState.rng.randi_range(0, description_variants.size() - 1)]

func generate_room(stage: int) -> RoomResource:
    var cache_key := RoomGenerator.get_cache_key(self, stage)
    if RoomGenerator.cache.has(cache_key):
        return RoomGenerator.cache[cache_key] as RestRoomResource

    var room := RestRoomResource.new()
    var stage_multiplier := 1.0 + (heal_scaling_per_stage * stage)
    room.heal_amount = int(round(base_heal_amount * stage_multiplier))

    if not rest_message_variants.is_empty():
        room.rest_message = rest_message_variants[GameState.rng.randi_range(0, rest_message_variants.size() - 1)]

    room.title = get_title()
    room.description = get_description()
    apply_common_properties(room)

    RoomGenerator.cache[cache_key] = room
    return room
