@tool
class_name ItemWeapon extends Item

@export var damage: int = 3

func _init() -> void:
    name = "Weapon"
    description = "Description of a weapon."
    consumable = false

func _on_use() -> void:
    GameState.equip_weapon(self)

func get_description() -> String:
    return "%s\nDamage: %d" % [description, damage]