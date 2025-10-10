@tool
class_name ItemWeapon extends Item

@export var damage: int = 3
@export var condition: int = 10  # Base condition when new

func _init() -> void:
    name = "Weapon"

func _on_use() -> bool:
    GameState.equip_weapon(self)
    return false

func on_attack_hit(_target: CombatEntity) -> void:
    # Default weapon does nothing special on hit
    pass