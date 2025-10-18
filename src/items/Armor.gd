@tool
class_name Armor extends Equippable

@export var defense_bonus: int = 5  # Base defense bonus provided by this armor
@export var armor_slot: Equippable.EquipSlot = Equippable.EquipSlot.CUIRASS

func _init() -> void:
    name = "Armor"

func get_category() -> Item.ItemCategory:
    return Item.ItemCategory.ARMOR

func get_equip_slot() -> Equippable.EquipSlot:
    return armor_slot

func is_valid_enchantment(enchant: Enchantment) -> bool:
    # Armor can only have constant effect enchantments
    return enchant is ConstantEffectEnchantment

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    var info: Array[AdditionalTooltipInfoData] = super.get_additional_tooltip_info()

    var defense_info := AdditionalTooltipInfoData.new()
    defense_info.text = "🛡️ Defense: +%d%%" % defense_bonus
    defense_info.color = Color(0.6, 0.8, 1.0)  # Light blue color for defense
    info.insert(0, defense_info)  # Insert at beginning so defense shows before enchantment

    return info

## Override to get the defense bonus this armor provides
func get_defense_bonus() -> int:
    return defense_bonus

func get_base_inventory_color() -> Color:
    return Color("#6e81a8ff")