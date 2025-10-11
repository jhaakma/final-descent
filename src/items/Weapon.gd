@tool
class_name ItemWeapon extends Item

@export var damage: int = 3
@export var condition: int = 10  # Base condition when new

func _init() -> void:
    name = "Weapon"

func get_consumable() -> bool:
    return false  # Weapons are not consumable

func _on_use(item_data: ItemData) -> bool:
    return GameState.player.equip_weapon(ItemInstance.new(self, item_data, 1))

func on_attack_hit(_target: CombatEntity) -> void:
    # Default weapon does nothing special on hit
    pass

func calculate_sell_value(item_data: ItemData = null) -> int:
    var base_sell_value := super.calculate_sell_value(item_data)
    # If item has condition data and is damaged, reduce sell value
    if item_data and item_data.current_condition < get_max_condition():
        var max_condition := get_max_condition()
        var condition_ratio := float(item_data.current_condition) / float(max_condition)
        # Apply condition modifier: full condition = 100%, broken = 10% of base value
        var condition_modifier: float = lerp(0.1, 1.0, condition_ratio)
        return int(base_sell_value * condition_modifier)
    return base_sell_value

func get_max_condition() -> int:
    return condition