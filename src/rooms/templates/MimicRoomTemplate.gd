class_name MimicRoomTemplate extends IRoomTemplate
## Template for mimic chest room generation

@export var title_variants: Array[String] = ["Treasure Chest"]
@export var description_variants: Array[String] = ["A chest sits before you."]
@export var mimic_enemy_generator: EnemyGenerator

func get_room_type() -> RoomType.Type:
    return RoomType.Type.MIMIC

func get_title() -> String:
    if title_variants.is_empty():
        return "Treasure Chest"
    return title_variants[GameState.rng.randi_range(0, title_variants.size() - 1)]

func get_description() -> String:
    if description_variants.is_empty():
        return "A chest sits before you."
    return description_variants[GameState.rng.randi_range(0, description_variants.size() - 1)]

func generate_room(stage: int) -> RoomResource:
    var cache_key := RoomGenerator.get_cache_key(self, stage)
    if RoomGenerator.cache.has(cache_key):
        return RoomGenerator.cache[cache_key] as MimicChestRoomResource

    var room := MimicChestRoomResource.new()
    room.mimic_enemy = mimic_enemy_generator.generate_enemy() if mimic_enemy_generator else null

    room.title = get_title()
    room.description = get_description()
    apply_common_properties(room)

    RoomGenerator.cache[cache_key] = room
    return room
