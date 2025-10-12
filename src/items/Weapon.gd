@tool
class_name Weapon extends Item

signal attack_hit(target: CombatEntity)
signal equip(weapon: Weapon)
signal unequip(weapon: Weapon)

@export var damage: int = 3
@export var condition: int = 10  # Base condition when new
@export var enchantment: Enchantment:
    set = set_enchantment

func _init() -> void:
    name = "Weapon"

func set_enchantment(_enchantment: Enchantment) -> void:
    if not _enchantment:
        enchantment = null
        return
    enchantment = _enchantment
    if _enchantment.is_valid_owner(self):
        _enchantment.initialise(self)
    else:
        print_debug("Warning: Enchantment %s is not valid for Weapon" % _enchantment.get_class())

func get_consumable() -> bool:
    return false  # Weapons are not consumable

func _on_use(item_data: ItemData) -> bool:
    return GameState.player.equip_weapon(ItemInstance.new(self, item_data, 1))

func on_attack_hit(_target: CombatEntity) -> void:
    attack_hit.emit(_target)

func on_equip() -> void:
    equip.emit(self)

func on_unequip() -> void:
    unequip.emit(self)

func calculate_sell_value(item_data: ItemData = null) -> int:
    return calculate_buy_value(item_data) / 2

func calculate_buy_value(item_data: ItemData = null) -> int:
    # If item has condition data and is damaged, reduce sell value
    if item_data and item_data.current_condition < get_max_condition():
        var max_condition := get_max_condition()
        var condition_ratio := float(item_data.current_condition) / float(max_condition)
        # Apply condition modifier: full condition = 100%, broken = 10% of base value
        var condition_modifier: float = lerp(0.1, 1.0, condition_ratio)
        return int(purchase_value * condition_modifier)
    return purchase_value

func get_max_condition() -> int:
    return condition

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    var info :Array[AdditionalTooltipInfoData]= []

    var damage_info := AdditionalTooltipInfoData.new()
    damage_info.text = "⚔️ Damage: %d" % damage
    damage_info.color = Color(1.0, 0.8, 0.6)
    info.append(damage_info)

    if enchantment:
        var enchantment_info := AdditionalTooltipInfoData.new()
        enchantment_info.text = "🔮 Enchantment: %s" % enchantment.get_description()
        enchantment_info.color = Color(0.8, 0.6, 1.0)
        info.append(enchantment_info)
    return info

func get_inventory_color() -> Color:
    if enchantment:
        return Color(0.8, 0.6, 1.0)  # Slightly purple tint for enchanted weapons
    return Color(1, 1, 1)  # Default color for non-enchanted weapons
