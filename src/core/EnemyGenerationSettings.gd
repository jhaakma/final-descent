class_name EnemyGenerationSettings extends Resource
## Configuration settings for enemy generation and stat calculation

## Level scaling factors
@export_group("Level Scaling")
## Multiplicative HP increase per level (0.25 = 25% more HP per level)
@export var hp_level_scaling: float = 0.25  # 25% increase per level
## Multiplicative attack increase per level (0.2 = 20% more attack per level)
@export var attack_level_scaling: float = 0.2  # 20% increase per level
## Additive defense increase per level (0.5 = +0.5 defense per level)
@export var defense_level_scaling: float = 0.5  # +0.5 defense per level

## Archetype base stats
@export_group("Archetype Base Stats")

@export_subgroup("Default")
## Default base HP - fallback archetype
@export var default_base_hp: int = 20
## Default base attack - fallback archetype
@export var default_base_attack: int = 3
## Default base defense - fallback archetype
@export var default_base_defense: int = 5
## Default base avoid chance - fallback archetype
@export var default_base_avoid_chance: float = 0.5

@export_subgroup("Warrior")
## Warrior base HP - balanced melee combatant
@export var warrior_base_hp: int = 25
## Warrior base attack - balanced damage output
@export var warrior_base_attack: int = 4
## Warrior base defense - moderate defensive capability
@export var warrior_base_defense: int = 10
## Warrior base avoid chance - moderate evasion
@export var warrior_base_avoid_chance: float = 0.6

@export_subgroup("Berserker")
## Barbarian base HP - glass cannon with lower survivability
@export var berserker_base_hp: int = 20
## Barbarian base attack - high damage at cost of defense
@export var berserker_base_attack: int = 6
## Barbarian base defense - minimal defensive capability
@export var berserker_base_defense: int = 0
## Barbarian base avoid chance - low evasion
@export var berserker_base_avoid_chance: float = 0.3

@export_subgroup("Tank")
## Tank base HP - high survivability tank role
@export var tank_base_hp: int = 40
## Tank base attack - lower damage for defensive role
@export var tank_base_attack: int = 3
## Tank base defense - high defensive capability
@export var tank_base_defense: int = 20
## Tank base avoid chance - very low evasion
@export var tank_base_avoid_chance: float = 0.8

## Size category modifiers
@export_group("Size Modifiers")

@export_subgroup("Small")
## Small creature HP multiplier - reduced health for agility
@export var small_hp_modifier: float = 0.7
## Small creature attack multiplier - slightly reduced damage
@export var small_attack_modifier: float = 0.8
## Small creature avoid bonus - harder to hit due to size
@export var small_avoid_bonus: float = 0.2

@export_subgroup("Medium")
## Medium creature HP multiplier - baseline size
@export var medium_hp_modifier: float = 1.0
## Medium creature attack multiplier - baseline damage
@export var medium_attack_modifier: float = 1.0

@export_subgroup("Large")
## Large creature HP multiplier - increased bulk and survivability
@export var large_hp_modifier: float = 1.3
## Large creature attack multiplier - stronger attacks due to size
@export var large_attack_modifier: float = 1.2
## Large creature defense bonus - natural armor from size
@export var large_defense_bonus: int = 1
## Large creature avoid penalty - easier to hit due to size
@export var large_avoid_penalty: float = -0.1

@export_subgroup("Huge")
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

## Get archetype base stats as a dictionary for easier access
func get_archetype_data(archetype: EnemyTemplate.EnemyArchetype) -> Dictionary:
    match archetype:
        EnemyTemplate.EnemyArchetype.WARRIOR:
            return {
                "base_hp": warrior_base_hp,
                "base_attack": warrior_base_attack,
                "base_defense": warrior_base_defense,
                "base_avoid_chance": warrior_base_avoid_chance
            }
        EnemyTemplate.EnemyArchetype.BERSERKER:
            return {
                "base_hp": berserker_base_hp,
                "base_attack": berserker_base_attack,
                "base_defense": berserker_base_defense,
                "base_avoid_chance": berserker_base_avoid_chance
            }
        EnemyTemplate.EnemyArchetype.TANK:
            return {
                "base_hp": tank_base_hp,
                "base_attack": tank_base_attack,
                "base_defense": tank_base_defense,
                "base_avoid_chance": tank_base_avoid_chance
            }
        _:
            return {
                "base_hp": default_base_hp,
                "base_attack": default_base_attack,
                "base_defense": default_base_defense,
                "base_avoid_chance": default_base_avoid_chance
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