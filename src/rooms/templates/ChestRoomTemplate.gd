class_name ChestRoomTemplate extends IRoomTemplate
## Template for chest room generation

## Title and Description are matched by their array positions
@export var title_variants: Array[String] = ["Treasure Chest"]
## Title and Description are matched by their array positions
@export var description_variants: Array[String] = ["A chest sits before you."]

@export var base_loot_component: LootComponent
@export var gold_scaling_per_stage: float = 0.1
@export var chance_empty: float = 0.2

func get_room_type() -> RoomType.Type:
    return RoomType.Type.CHEST

func set_title_and_description(room: ChestRoomResource) -> void:
    var size: int = min(title_variants.size(), description_variants.size())
    if size > 0:
        var index: int = GameState.rng.randi_range(0, size - 1)
        room.title = title_variants[index]
        room.description = description_variants[index]
    else:
        room.title = "Treasure Chest"
        room.description = "A chest sits before you."

func generate_room(stage: int) -> RoomResource:
    var cache_key := RoomGenerator.get_cache_key(self, stage)
    if RoomGenerator.cache.has(cache_key):
        return RoomGenerator.cache[cache_key] as ChestRoomResource

    var room := ChestRoomResource.new()
    if base_loot_component:
        room.loot_component = RoomGenerator.scale_loot_component(base_loot_component, stage, gold_scaling_per_stage)
    room.chance_empty = chance_empty
    apply_common_properties(room)
    set_title_and_description(room)

    RoomGenerator.cache[cache_key] = room
    return room

