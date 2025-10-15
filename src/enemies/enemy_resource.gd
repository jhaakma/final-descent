class_name EnemyResource extends Resource

@export var abilities: Array[Ability] = []  # New ability system
@export var name: String = "Enemy"
@export var max_hp: int = 10
@export var attack: int = 2
@export var defense: int = 0
@export var loot_component: LootComponent = LootComponent.new()
@export var avoid_chance: float = 0.5 #Chance to escape when selecting avoid
@export var ai_component: EnemyAIComponent = RandomAIComponent.new()
@export var resistances: Array[DamageType.Type] = []  # Damage types this enemy resists
@export var weaknesses: Array[DamageType.Type] = []  # Damage types this enemy is weak to

func get_abilities() -> Array[Ability]:
    return abilities
