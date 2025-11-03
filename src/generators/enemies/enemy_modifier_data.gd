class_name EnemyModifierData extends RefCounted
## Data container for enemy modifier properties

var health_modifier: float = 1.0
var attack_modifier: float = 1.0
var defense_modifier: float = 1.0
var avoid_chance_modifier: float = 0.0
var name_prefix: String = ""
var name_suffix: String = ""
var additional_abilities: Array[AbilityResource] = []
var additional_resistances: Array[DamageType.Type] = []
var additional_weaknesses: Array[DamageType.Type] = []
var rarity_weight: float = 1.0
var can_stack: bool = false  # Whether multiple of this modifier can apply

func _init(
    p_health_modifier: float = 1.0,
    p_attack_modifier: float = 1.0,
    p_defense_modifier: float = 1.0,
    p_avoid_chance_modifier: float = 0.0,
    p_name_prefix: String = "",
    p_name_suffix: String = "",
    p_additional_abilities: Array[AbilityResource] = [],
    p_additional_resistances: Array[DamageType.Type] = [],
    p_additional_weaknesses: Array[DamageType.Type] = [],
    p_rarity_weight: float = 1.0,
    p_can_stack: bool = false
) -> void:
    health_modifier = p_health_modifier
    attack_modifier = p_attack_modifier
    defense_modifier = p_defense_modifier
    avoid_chance_modifier = p_avoid_chance_modifier
    name_prefix = p_name_prefix
    name_suffix = p_name_suffix
    additional_abilities = p_additional_abilities
    additional_resistances = p_additional_resistances
    additional_weaknesses = p_additional_weaknesses
    rarity_weight = p_rarity_weight
    can_stack = p_can_stack

# Static factory method with clear parameter names
static func create(
    p_health_modifier: float = 1.0,
    p_attack_modifier: float = 1.0,
    p_defense_modifier: float = 1.0,
    p_avoid_chance_modifier: float = 0.0,
    p_name_prefix: String = "",
    p_name_suffix: String = "",
    p_additional_abilities: Array[AbilityResource] = [],
    p_additional_resistances: Array[DamageType.Type] = [],
    p_additional_weaknesses: Array[DamageType.Type] = [],
    p_rarity_weight: float = 1.0,
    p_can_stack: bool = false
) -> EnemyModifierData:
    return EnemyModifierData.new(
        p_health_modifier, p_attack_modifier, p_defense_modifier,
        p_avoid_chance_modifier, p_name_prefix, p_name_suffix, p_additional_abilities,
        p_additional_resistances, p_additional_weaknesses, p_rarity_weight, p_can_stack
    )

# Helper function to create with inline property setting
static func of(config: Dictionary) -> EnemyModifierData:
    var data := EnemyModifierData.new()
    if config.has("health_modifier"):
        data.health_modifier = config.health_modifier
    if config.has("attack_modifier"):
        data.attack_modifier = config.attack_modifier
    if config.has("defense_modifier"):
        data.defense_modifier = config.defense_modifier
    if config.has("avoid_chance_modifier"):
        data.avoid_chance_modifier = config.avoid_chance_modifier
    if config.has("name_prefix"):
        data.name_prefix = config.name_prefix
    if config.has("name_suffix"):
        data.name_suffix = config.name_suffix
    if config.has("additional_abilities"):
        data.additional_abilities = config.additional_abilities
    if config.has("additional_resistances"):
        data.additional_resistances = config.additional_resistances
    if config.has("additional_weaknesses"):
        data.additional_weaknesses = config.additional_weaknesses
    if config.has("rarity_weight"):
        data.rarity_weight = config.rarity_weight
    if config.has("can_stack"):
        data.can_stack = config.can_stack
    return data