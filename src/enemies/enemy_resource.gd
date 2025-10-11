class_name EnemyResource extends Resource

@export var abilities: Array[Ability] = []  # New ability system
@export var name: String = "Enemy"
@export var max_hp: int = 10
@export var attack: int = 2
@export var loot_component: LootComponent = LootComponent.new()
@export var avoid_chance: float = 0.5 #Chance to escape when selecting avoid
@export var ai_component: EnemyAIComponent = RandomAIComponent.new()

func get_abilities() -> Array[Ability]:
    return abilities
