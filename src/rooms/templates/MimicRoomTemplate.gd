class_name MimicRoomTemplate extends IRoomTemplate
## Template for mimic chest room generation

@export var title_variants: Array[String] = ["Treasure Chest"]
@export var description_variants: Array[String] = ["A chest sits before you."]
@export var mimic_enemy_generator: EnemyGenerator
@export var loot_component: LootComponent
@export var button_label: String = "Open Chest"
@export var button_tooltip: String = "Open the chest to see what's inside"

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
    var stage_number := StageProgressionManager.get_stage_number()
    room.mimic_enemy = mimic_enemy_generator.generate_enemy(stage_number) if mimic_enemy_generator else null
    room.loot_component = RoomGenerator.scale_loot_component(loot_component, stage, 0.1)
    room.title = get_title()
    room.description = get_description()
    room.button_label = button_label
    room.button_tooltip = button_tooltip
    apply_common_properties(room)

    RoomGenerator.cache[cache_key] = room
    return room
