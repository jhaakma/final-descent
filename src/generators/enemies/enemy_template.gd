class_name EnemyTemplate extends Resource
## Template for enemy generation - defines base properties before stat calculation

## Enemy archetype determines combat role and stat distribution
enum EnemyArchetype {
    WARRIOR,    ## Balanced melee combatant
    BARBARIAN,  ## High damage, lower defense
    TANK        ## High defense, lower damage
}

## Size category affects stats and available abilities
enum SizeCategory {
    SMALL,   ## Small creatures - agile, less HP
    MEDIUM,  ## Medium creatures - baseline
    LARGE,   ## Large creatures - more HP, some abilities
    HUGE     ## Huge creatures - massive stats, powerful abilities
}

## Elemental affinity affects resistances and abilities
enum ElementAffinity {
    NONE,     ## No elemental affinity
    FIRE,     ## Fire-based, resists fire, weak to ice
    ICE,      ## Ice-based, resists ice, weak to fire
    SHOCK,    ## Shock-based, resists shock
    POISON,   ## Poison-based, resists poison
    TOXIC,    ## Alias for poison (for compatibility)
    HOLY,     ## Holy-based, resists holy, weak to dark
    DARK      ## Dark-based, resists dark, weak to holy
}

## Ability templates that can be generated for enemies
enum AbilityTemplate {
    BASIC_ATTACK,       ## Standard attack ability (always included)
    BASIC_STRIKE,       ## Basic melee strike
    ELEMENTAL_STRIKE,   ## Strike with elemental damage matching affinity
    BREATH_ATTACK,      ## Breath weapon (requires LARGE or HUGE size)
    POISON_ATTACK,      ## Poison-based attack
    DEFEND,             ## Defensive ability
    HEAL,               ## Self-healing ability
    BUFF_ATTACK,        ## Buff own attack
    BUFF_DEFENSE        ## Buff own defense
}

## Base properties
@export var base_name: String = "Enemy"
@export var base_level: int = 1
@export var archetype: EnemyArchetype = EnemyArchetype.WARRIOR
@export var size_category: SizeCategory = SizeCategory.MEDIUM
@export var element_affinity: ElementAffinity = ElementAffinity.NONE

## Ability configuration
@export var ability_templates: Array[AbilityTemplate] = []

## Modifier configuration
@export var possible_modifiers: Array[EnemyModifierResolver.ModifierType] = []
@export var modifier_chance: float = 0.0  ## Chance to apply a modifier (0.0 = never, 1.0 = always)

## Get element prefix for naming
func get_element_prefix() -> String:
    match element_affinity:
        ElementAffinity.FIRE:
            return "Fire"
        ElementAffinity.ICE:
            return "Ice"
        ElementAffinity.SHOCK:
            return "Shock"
        ElementAffinity.POISON, ElementAffinity.TOXIC:
            return "Toxic"
        ElementAffinity.HOLY:
            return "Holy"
        ElementAffinity.DARK:
            return "Dark"
        _:
            return ""

## Get elemental resistances based on affinity
func get_elemental_resistances() -> Array[DamageType.Type]:
    var resistances: Array[DamageType.Type] = []
    match element_affinity:
        ElementAffinity.FIRE:
            resistances.append(DamageType.Type.FIRE)
        ElementAffinity.ICE:
            resistances.append(DamageType.Type.ICE)
        ElementAffinity.SHOCK:
            resistances.append(DamageType.Type.SHOCK)
        ElementAffinity.POISON, ElementAffinity.TOXIC:
            resistances.append(DamageType.Type.POISON)
        ElementAffinity.HOLY:
            resistances.append(DamageType.Type.HOLY)
        ElementAffinity.DARK:
            resistances.append(DamageType.Type.DARK)
    return resistances

## Get elemental weaknesses based on affinity
func get_elemental_weaknesses() -> Array[DamageType.Type]:
    var weaknesses: Array[DamageType.Type] = []
    match element_affinity:
        ElementAffinity.FIRE:
            weaknesses.append(DamageType.Type.ICE)
        ElementAffinity.ICE:
            weaknesses.append(DamageType.Type.FIRE)
        ElementAffinity.HOLY:
            weaknesses.append(DamageType.Type.DARK)
        ElementAffinity.DARK:
            weaknesses.append(DamageType.Type.HOLY)
    return weaknesses
