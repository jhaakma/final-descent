class_name ShrineRoomTemplate extends IRoomTemplate
## Template for shrine room generation

@export var title_variants: Array[String] = ["Shrine"]
@export var description_variants: Array[String] = ["A mystical shrine radiates power."]
@export var base_blessing_cost: int = 20
@export var base_cure_cost: int = 15
@export var base_heal_cost: int = 10
@export var cost_scaling_per_stage: float = 0.1
@export var blessing_templates: Array[StatusConditionTemplate] = []
@export var base_loot_component: LootComponent
@export var loot_curse_chance: float = 0.3
@export var curse_enemy_generator: EnemyGenerator

func get_room_type() -> RoomType.Type:
    return RoomType.Type.SHRINE

func get_title() -> String:
    if title_variants.is_empty():
        return "Shrine"
    return title_variants[GameState.rng.randi_range(0, title_variants.size() - 1)]

func get_description() -> String:
    if description_variants.is_empty():
        return "A mystical shrine radiates power."
    return description_variants[GameState.rng.randi_range(0, description_variants.size() - 1)]

func generate_room(stage: int) -> RoomResource:
    var cache_key := RoomGenerator.get_cache_key(self, stage)
    if RoomGenerator.cache.has(cache_key):
        return RoomGenerator.cache[cache_key] as ShrineRoomResource

    var room := ShrineRoomResource.new()
    var cost_multiplier := 1.0 + (cost_scaling_per_stage * stage)
    room.blessing_cost = int(round(base_blessing_cost * cost_multiplier))
    room.cure_cost = int(round(base_cure_cost * cost_multiplier))
    room.heal_cost = int(round(base_heal_cost * cost_multiplier))
    room.blessing_templates = blessing_templates.duplicate()
    room.loot_component = RoomGenerator.scale_loot_component(base_loot_component, stage, 0.1)
    room.loot_curse_chance = loot_curse_chance
    room.curse_enemy = curse_enemy_generator.generate_enemy() if curse_enemy_generator else null

    room.title = get_title()
    room.description = get_description()
    apply_common_properties(room)

    RoomGenerator.cache[cache_key] = room
    return room
