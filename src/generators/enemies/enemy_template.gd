class_name EnemyTemplate extends Resource
## Template for enemy generation - defines base properties before stat calculation

## Enemy archetype determines combat role and stat distribution
enum EnemyArchetype {
    DEFAULT,   ## Fallback archetype
    WARRIOR,    ## Balanced melee combatant
    BERSERKER,  ## High damage, lower defense
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
    HOLY,     ## Holy-based, resists holy, weak to dark
    DARK      ## Dark-based, resists dark, weak to holy
}

## Base properties
@export var base_name: String = "Enemy"
@export var archetype: EnemyArchetype = EnemyArchetype.WARRIOR
@export var size_category: SizeCategory = SizeCategory.MEDIUM
@export var element_affinity: ElementAffinity = ElementAffinity.NONE
@export var physical_attack_type: DamageType.Type = DamageType.Type.BLUNT  ## Physical damage type for basic attacks

## Ability configuration - use AbilityTemplate resources
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

## Helper method to add a basic attack template
func add_basic_attack() -> EnemyTemplate:
    ability_templates.append(BasicAttackTemplate.new())
    return self

## Helper method to add a basic strike template
func add_basic_strike() -> EnemyTemplate:
    ability_templates.append(BasicStrikeTemplate.new())
    return self

## Helper method to add an elemental strike template
func add_elemental_strike() -> EnemyTemplate:
    ability_templates.append(ElementalStrikeTemplate.new())
    return self

## Helper method to add a breath attack template
func add_breath_attack() -> EnemyTemplate:
    ability_templates.append(BreathAttackTemplate.new())
    return self

## Helper method to add a poison attack template
func add_poison_attack() -> EnemyTemplate:
    ability_templates.append(PoisonAttackTemplate.new())
    return self

## Helper method to add a defend template
func add_defend() -> EnemyTemplate:
    ability_templates.append(DefendTemplate.new())
    return self
