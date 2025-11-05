class_name EnemyModifierResolver extends RefCounted
## Responsible for resolving and providing access to different enemy modifier types

# Enum for referencing different modifier types
enum ModifierType {
    NONE,      # No modifier
    ELITE,     # Elite variant - stronger overall
    CHAMPION,  # Champion variant - boss-level
    ANCIENT,   # Ancient variant - old and powerful
    YOUNG,     # Young variant - weaker but agile
    ARMORED,   # Armored variant - high defense
    BERSERKER, # Berserker variant - high attack, low defense
    SWIFT,     # Swift variant - agile and evasive
    GIANT,     # Giant variant - large and powerful
    TINY,      # Tiny variant - small and evasive
    DISEASED,  # Diseased variant - poison-based
    BLESSED,   # Blessed variant - holy resistance
    CURSED,    # Cursed variant - dark-aligned
}

# Static dictionary containing all modifier data
static var _modifier_data: Dictionary = {}

# Initialize the modifier data dictionary
static func _static_init() -> void:
    _modifier_data = {
        ModifierType.ELITE: EnemyModifierBuilder.create()
            .elite()
            .build(),

        ModifierType.CHAMPION: EnemyModifierBuilder.create()
            .champion()
            .build(),

        ModifierType.ANCIENT: EnemyModifierBuilder.create()
            .ancient()
            .build(),

        ModifierType.YOUNG: EnemyModifierBuilder.create()
            .young()
            .build(),

        ModifierType.ARMORED: EnemyModifierBuilder.create()
            .armored()
            .build(),

        ModifierType.BERSERKER: EnemyModifierBuilder.create()
            .berserker()
            .build(),

        ModifierType.SWIFT: EnemyModifierBuilder.create()
            .swift()
            .build(),

        ModifierType.GIANT: EnemyModifierBuilder.create()
            .giant()
            .build(),

        ModifierType.TINY: EnemyModifierBuilder.create()
            .tiny()
            .build(),

        ModifierType.DISEASED: EnemyModifierBuilder.create()
            .diseased()
            .build(),

        ModifierType.BLESSED: EnemyModifierBuilder.create()
            .blessed()
            .build(),

        ModifierType.CURSED: EnemyModifierBuilder.create()
            .cursed()
            .build(),
    }

static func get_modifier_data(modifier_type: ModifierType) -> EnemyModifierData:
    """Get the complete modifier data for a modifier type"""
    if _modifier_data.is_empty():
        _static_init()
    return _modifier_data.get(modifier_type, null)

static func get_all_modifier_types() -> Array[ModifierType]:
    """Get all available modifier types"""
    var types: Array[ModifierType] = []
    for type_value: ModifierType in ModifierType.values():
        types.append(type_value)
    return types

static func get_weighted_modifier_types() -> Dictionary:
    """Get modifier types with their rarity weights for weighted random selection"""
    if _modifier_data.is_empty():
        _static_init()

    var weighted_types: Dictionary = {}
    for modifier_type: ModifierType in _modifier_data.keys():
        var data: EnemyModifierData = _modifier_data[modifier_type]
        weighted_types[modifier_type] = data.rarity_weight

    return weighted_types

static func select_random_modifier() -> ModifierType:
    """Select a random modifier using weighted selection based on rarity"""
    var weighted_types := get_weighted_modifier_types()

    var total_weight: float = 0.0
    for weight: float in weighted_types.values():
        total_weight += weight

    var random_value := GameState.rng.randf() * total_weight
    var current_weight: float = 0.0

    for modifier_type: ModifierType in weighted_types.keys():
        current_weight += weighted_types[modifier_type]
        if random_value <= current_weight:
            return modifier_type

    # Fallback to first available modifier
    return get_all_modifier_types()[0]


static func apply_modifier_to_enemy(modifier_type: ModifierType, enemy: EnemyResource) -> void:
    """Apply a modifier's effects to an enemy resource"""
    var modifier_data := get_modifier_data(modifier_type)
    if modifier_data == null:
        push_error("Unknown modifier type: %s" % modifier_type)
        return

    # Apply stat modifiers
    enemy.max_hp = int(round(enemy.max_hp * modifier_data.health_modifier))
    enemy.attack = int(round(enemy.attack * modifier_data.attack_modifier))
    enemy.defense = int(round(enemy.defense * modifier_data.defense_modifier))
    enemy.avoid_chance = clamp(enemy.avoid_chance + modifier_data.avoid_chance_modifier, 0.0, 1.0)

    # Modify name
    if not modifier_data.name_prefix.is_empty() or not modifier_data.name_suffix.is_empty():
        enemy.name = "%s%s%s" % [
            modifier_data.name_prefix + (" " if not modifier_data.name_prefix.is_empty() else ""),
            enemy.name,
            (" " + modifier_data.name_suffix if not modifier_data.name_suffix.is_empty() else "")
        ]

    # Add abilities
    for ability in modifier_data.additional_abilities:
        if ability and not enemy.abilities.has(ability):
            enemy.abilities.append(ability)

    # Add resistances
    for resistance in modifier_data.additional_resistances:
        if not enemy.resistances.has(resistance):
            enemy.resistances.append(resistance)

    # Add weaknesses
    for weakness in modifier_data.additional_weaknesses:
        if not enemy.weaknesses.has(weakness):
            enemy.weaknesses.append(weakness)