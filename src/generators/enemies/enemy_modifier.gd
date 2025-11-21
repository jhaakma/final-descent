class_name EnemyModifier extends Resource
## Resource defining a modifier that can be applied to enemies
##
## Modifiers can be assigned to enemy templates and will modify
## enemy stats, add abilities, resistances, etc when applied.

@export var modifier_name: String = ""
@export var health_modifier: float = 1.0
@export var attack_modifier: float = 1.0
@export var defense_modifier: float = 1.0
@export var avoid_chance_modifier: float = 0.0
@export var name_prefix: String = ""
@export var name_suffix: String = ""
@export var additional_abilities: Array[AbilityResource] = []
@export var additional_resistances: Array[DamageType.Type] = []
@export var additional_weaknesses: Array[DamageType.Type] = []
@export var rarity_weight: float = 1.0  ## Higher = more common
@export var can_stack: bool = false  ## Whether multiple of this modifier can apply

## Apply this modifier to an enemy resource
func apply_to_enemy(enemy: EnemyResource) -> void:
    # Apply stat modifiers
    enemy.max_hp = int(round(enemy.max_hp * health_modifier))
    enemy.attack = int(round(enemy.attack * attack_modifier))
    enemy.defense = int(round(enemy.defense * defense_modifier))
    enemy.avoid_chance = clamp(enemy.avoid_chance + avoid_chance_modifier, 0.0, 1.0)

    # Modify name
    if not name_prefix.is_empty() or not name_suffix.is_empty():
        enemy.name = "%s%s%s" % [
            name_prefix + (" " if not name_prefix.is_empty() else ""),
            enemy.name,
            (" " + name_suffix if not name_suffix.is_empty() else "")
        ]

    # Add abilities
    for ability: AbilityResource in additional_abilities:
        if ability and not enemy.abilities.has(ability):
            enemy.abilities.append(ability)

    # Add resistances
    for resistance: DamageType.Type in additional_resistances:
        if not enemy.resistances.has(resistance):
            enemy.resistances.append(resistance)

    # Add weaknesses
    for weakness: DamageType.Type in additional_weaknesses:
        if not enemy.weaknesses.has(weakness):
            enemy.weaknesses.append(weakness)
