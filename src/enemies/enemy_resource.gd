class_name EnemyResource extends Resource

@export var abilities: Array[AbilityResource] = []  # New ability system
@export var name: String = "Enemy"
@export var max_hp: int = 10
@export var attack: int = 2
@export var defense: int = 0
@export var loot_component: LootComponent = LootComponent.new()
@export var avoid_chance: float = 0.5 #Chance to escape when selecting avoid
@export var ai_component: EnemyAIComponent = RandomAIComponent.new()
@export var resistances: Array[DamageType.Type] = []  # Damage types this enemy resists
@export var weaknesses: Array[DamageType.Type] = []  # Damage types this enemy is weak to

## Properties for ability template generation
@export var level: int = 1  # Enemy level for ability scaling
@export var element_affinity: EnemyTemplate.ElementAffinity = EnemyTemplate.ElementAffinity.NONE  # Element affinity for abilities

func get_abilities() -> Array[AbilityResource]:
    return abilities

func get_level() -> int:
    return level

func get_element_affinity() -> EnemyTemplate.ElementAffinity:
    return element_affinity
