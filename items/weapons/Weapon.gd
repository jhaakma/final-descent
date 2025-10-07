@tool
class_name ItemWeapon extends Item

@export var damage: int = 3
@export var condition: int = 10  # Base condition when new

func _init() -> void:
    name = "Weapon"
    description = "Description of a weapon."
    consumable = false

func _on_use() -> void:
    GameState.equip_weapon(self)
