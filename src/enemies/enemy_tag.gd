## Descriptive tag that modifies enemy stats through multipliers and bonuses
## Tags describe enemy characteristics in English terms (Fast, Tough, Magical, etc.)
class_name EnemyTag extends Resource

@export var name: String = "Tough"
@export var description: String = "Increases enemy health and defense."

# Stat multipliers (multiplicative bonuses)
@export var hp_multiplier: float = 1.2
@export var attack_multiplier: float = 1.0
@export var defense_multiplier: float = 1.2

# Flat stat bonuses (additive bonuses applied after multipliers)
@export var hp_bonus: int = 0
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0

# Resistance/weakness modifications
@export var grants_resistances: Array[DamageType.Type] = []
@export var grants_weaknesses: Array[DamageType.Type] = []
@export var removes_resistances: Array[DamageType.Type] = []
@export var removes_weaknesses: Array[DamageType.Type] = []

# Special abilities this tag grants
@export var granted_abilities: Array[Ability] = []

# Archetype restrictions (empty = compatible with all)
@export var restricted_archetypes: Array[EnemyArchetype.Category] = []

# Visual/name modifications
@export var name_prefix: String = ""  # e.g., "Giant"
@export var name_suffix: String = ""  # e.g., "of Fire"

# Tag category for organizing and preventing conflicts
enum TagType {
    SIZE,       # Giant, Tiny, Large
    ELEMENTAL,  # Fire, Ice, Shock
    TOUGHNESS,  # Tough, Fragile, Armored
    SPEED,      # Fast, Slow, Lightning
    MAGICAL,    # Magical, Enchanted, Cursed
    BEHAVIORAL, # Aggressive, Defensive, Cowardly
    SPECIAL     # Unique, Boss, Elite
}

@export var tag_type: TagType = TagType.TOUGHNESS

## Apply this tag's effects to base stats
func apply_to_stats(base_stats: Dictionary) -> Dictionary:
    var modified_stats := base_stats.duplicate()

    # Apply multipliers first
    modified_stats.health = int(modified_stats.health * hp_multiplier) + hp_bonus
    modified_stats.attack = int(modified_stats.attack * attack_multiplier) + attack_bonus
    modified_stats.defense = int(modified_stats.defense * defense_multiplier) + defense_bonus

    return modified_stats

## Check if this tag conflicts with another tag
func conflicts_with(other_tag: EnemyTag) -> bool:
    # Tags of the same type usually conflict (e.g., can't be both Giant and Tiny)
    if tag_type == other_tag.tag_type:
        # Some exceptions for compatible combinations
        match tag_type:
            TagType.MAGICAL:
                return false  # Multiple magical effects can stack
            TagType.BEHAVIORAL:
                return false  # Can have multiple behavioral traits
            _:
                return true
    return false

## Get the display name modification this tag provides
func get_name_modification() -> Dictionary:
    return {
        "prefix": name_prefix,
        "suffix": name_suffix
    }
