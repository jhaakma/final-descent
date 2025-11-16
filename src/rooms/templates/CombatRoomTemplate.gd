class_name CombatRoomTemplate extends IRoomTemplate
## Template for combat room generation

@export var title_variants: Array[String] = ["Combat"]
@export var description_variants: Array[String] = ["Enemies block your path."]
@export var enemy_generator: EnemyGenerator

func get_room_type() -> RoomType.Type:
    return RoomType.Type.COMBAT

func get_title() -> String:
    if title_variants.is_empty():
        return "Combat"
    return title_variants[GameState.rng.randi_range(0, title_variants.size() - 1)]

func get_description() -> String:
    if description_variants.is_empty():
        return "Enemies block your path."
    return description_variants[GameState.rng.randi_range(0, description_variants.size() - 1)]

func generate_room(stage: int) -> RoomResource:
    var cache_key := RoomGenerator.get_cache_key(self, stage)
    if RoomGenerator.cache.has(cache_key):
        return RoomGenerator.cache[cache_key] as CombatRoomResource

    var room := CombatRoomResource.new()
    room.enemy_generator = enemy_generator
    room.title = get_title()
    room.description = get_description()
    apply_common_properties(room)

    RoomGenerator.cache[cache_key] = room
    return room
