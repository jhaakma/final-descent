class_name EnemyResource extends Resource

@export var special_attacks: Array[SpecialAttack] = []
@export var name: String = "Enemy"
@export var max_hp: int = 10
@export var attack: int = 2
@export var loot_component: LootComponent = LootComponent.new()
@export var avoid_chance: float = 0.5 #Chance to escape when selecting avoid

func get_special_attacks() -> Array[SpecialAttack]:
    return special_attacks