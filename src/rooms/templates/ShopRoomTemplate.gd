class_name ShopRoomTemplate extends IRoomTemplate
## Template for shop room generation

@export var title_variants: Array[String] = ["Shop"]
@export var description_variants: Array[String] = ["A merchant offers their wares."]
@export var base_loot_component: LootComponent
@export var gold_scaling_per_stage: float = 0.1

func get_room_type() -> RoomType.Type:
    return RoomType.Type.SHOP

func get_title() -> String:
    if title_variants.is_empty():
        return "Shop"
    return title_variants[GameState.rng.randi_range(0, title_variants.size() - 1)]

func get_description() -> String:
    if description_variants.is_empty():
        return "A merchant offers their wares."
    return description_variants[GameState.rng.randi_range(0, description_variants.size() - 1)]

func generate_room(stage: int) -> RoomResource:
    var cache_key := RoomGenerator.get_cache_key(self, stage)
    if RoomGenerator.cache.has(cache_key):
        return RoomGenerator.cache[cache_key] as ShopkeeperRoomResource

    var room := ShopkeeperRoomResource.new()
    room.loot_component = RoomGenerator.scale_loot_component(base_loot_component, stage, gold_scaling_per_stage)

    room.title = get_title()
    room.description = get_description()
    apply_common_properties(room)

    RoomGenerator.cache[cache_key] = room
    return room
