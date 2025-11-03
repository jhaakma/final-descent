class_name EnemyGenerationSettings extends Resource
## Configuration settings for enemy generation and stat calculation

## Base stat values
@export_group("Base Stats")
## Starting health points for all enemies before modifiers
@export var base_hp: int = 25
## Starting attack damage for all enemies before modifiers
@export var base_attack: int = 4
## Starting defense value for all enemies before modifiers
@export var base_defense: int = 0
## Starting chance to avoid attacks (0.0 = never, 1.0 = always)
@export var base_avoid_chance: float = 0.5

## Level scaling factors
@export_group("Level Scaling")
## Multiplicative HP increase per level (0.25 = 25% more HP per level)
@export var hp_level_scaling: float = 0.25  # 25% increase per level
## Multiplicative attack increase per level (0.2 = 20% more attack per level)
@export var attack_level_scaling: float = 0.2  # 20% increase per level
## Additive defense increase per level (0.5 = +0.5 defense per level)
@export var defense_level_scaling: float = 0.5  # +0.5 defense per level

## Archetype modifiers
@export_group("Archetype Modifiers")
## Warrior HP multiplier - balanced melee combatant
@export var warrior_hp_modifier: float = 1.0
## Warrior attack multiplier - balanced damage output
@export var warrior_attack_modifier: float = 1.0
## Warrior defense bonus - moderate defensive capability
@export var warrior_defense_bonus: int = 1

## Barbarian HP multiplier - glass cannon with lower survivability
@export var barbarian_hp_modifier: float = 0.8
## Barbarian attack multiplier - high damage at cost of defense
@export var barbarian_attack_modifier: float = 1.4
## Barbarian defense bonus - minimal defensive capability
@export var barbarian_defense_bonus: int = 0

## Tank HP multiplier - high survivability tank role
@export var tank_hp_modifier: float = 1.5
## Tank attack multiplier - lower damage for defensive role
@export var tank_attack_modifier: float = 0.8
## Tank defense bonus - high defensive capability
@export var tank_defense_bonus: int = 2

## Size category modifiers
@export_group("Size Modifiers")
## Small creature HP multiplier - reduced health for agility
@export var small_hp_modifier: float = 0.7
## Small creature attack multiplier - slightly reduced damage
@export var small_attack_modifier: float = 0.8
## Small creature avoid bonus - harder to hit due to size
@export var small_avoid_bonus: float = 0.2

## Medium creature HP multiplier - baseline size
@export var medium_hp_modifier: float = 1.0
## Medium creature attack multiplier - baseline damage
@export var medium_attack_modifier: float = 1.0

## Large creature HP multiplier - increased bulk and survivability
@export var large_hp_modifier: float = 1.3
## Large creature attack multiplier - stronger attacks due to size
@export var large_attack_modifier: float = 1.2
## Large creature defense bonus - natural armor from size
@export var large_defense_bonus: int = 1
## Large creature avoid penalty - easier to hit due to size
@export var large_avoid_penalty: float = -0.1

## Huge creature HP multiplier - massive health pool
@export var huge_hp_modifier: float = 1.8
## Huge creature attack multiplier - devastating attacks
@export var huge_attack_modifier: float = 1.5
## Huge creature defense bonus - significant natural armor
@export var huge_defense_bonus: int = 2
## Huge creature avoid penalty - very easy to hit due to size
@export var huge_avoid_penalty: float = -0.2

## Static accessor for global settings
static var instance: EnemyGenerationSettings

static func get_instance() -> EnemyGenerationSettings:
    if not instance:
        # Try to load from resources first
        var loaded_settings := load("res://data/settings/enemy_generation_settings.tres") as EnemyGenerationSettings
        if loaded_settings:
            instance = loaded_settings
        else:
            # Create default instance
            instance = EnemyGenerationSettings.new()
    return instance

## Get archetype modifiers as a dictionary for easier access
func get_archetype_data(archetype: EnemyTemplate.EnemyArchetype) -> Dictionary:
    match archetype:
        EnemyTemplate.EnemyArchetype.WARRIOR:
            return {
                "hp_modifier": warrior_hp_modifier,
                "attack_modifier": warrior_attack_modifier,
                "defense_bonus": warrior_defense_bonus
            }
        EnemyTemplate.EnemyArchetype.BARBARIAN:
            return {
                "hp_modifier": barbarian_hp_modifier,
                "attack_modifier": barbarian_attack_modifier,
                "defense_bonus": barbarian_defense_bonus
            }
        EnemyTemplate.EnemyArchetype.TANK:
            return {
                "hp_modifier": tank_hp_modifier,
                "attack_modifier": tank_attack_modifier,
                "defense_bonus": tank_defense_bonus
            }
        _:
            return {
                "hp_modifier": warrior_hp_modifier,
                "attack_modifier": warrior_attack_modifier,
                "defense_bonus": warrior_defense_bonus
            }

## Get size modifiers as a dictionary for easier access
func get_size_data(size: EnemyTemplate.SizeCategory) -> Dictionary:
    match size:
        EnemyTemplate.SizeCategory.SMALL:
            return {
                "hp_modifier": small_hp_modifier,
                "attack_modifier": small_attack_modifier,
                "defense_bonus": 0,
                "avoid_modifier": small_avoid_bonus
            }
        EnemyTemplate.SizeCategory.MEDIUM:
            return {
                "hp_modifier": medium_hp_modifier,
                "attack_modifier": medium_attack_modifier,
                "defense_bonus": 0,
                "avoid_modifier": 0.0
            }
        EnemyTemplate.SizeCategory.LARGE:
            return {
                "hp_modifier": large_hp_modifier,
                "attack_modifier": large_attack_modifier,
                "defense_bonus": large_defense_bonus,
                "avoid_modifier": large_avoid_penalty
            }
        EnemyTemplate.SizeCategory.HUGE:
            return {
                "hp_modifier": huge_hp_modifier,
                "attack_modifier": huge_attack_modifier,
                "defense_bonus": huge_defense_bonus,
                "avoid_modifier": huge_avoid_penalty
            }
        _:
            return {
                "hp_modifier": medium_hp_modifier,
                "attack_modifier": medium_attack_modifier,
                "defense_bonus": 0,
                "avoid_modifier": 0.0
            }