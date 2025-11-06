@tool
class_name Armor extends Equippable

@export var defense_bonus: int = 5  # Base defense bonus provided by this armor
@export var armor_slot: Equippable.EquipSlot = Equippable.EquipSlot.CUIRASS
@export var resistances: Dictionary = {}  # Damage type resistances (DamageType.Type -> bool)

var _base_defense: int = 0
var _base_condition: int = 0

func _init() -> void:
    name = "Armor"
    _base_name = ""  # Explicitly initialize base name

func get_category() -> Item.ItemCategory:
    return Item.ItemCategory.ARMOR

func get_equip_slot() -> Equippable.EquipSlot:
    return armor_slot

func is_valid_enchantment(enchant: Enchantment) -> bool:
    # Armor can only have constant effect enchantments
    return enchant is ConstantEffectEnchantment

## Override to apply modifier stat changes to armor
func _apply_modifier_to_stats() -> void:
    super._apply_modifier_to_stats()

    if not modifier:
        return

    # Store base values if not already stored
    if _base_defense == 0:
        _base_defense = defense_bonus
    if _base_condition == 0:
        _base_condition = condition

    # Apply modifier bonuses to stats
    defense_bonus = int(_base_defense * modifier.defense_modifier)
    var new_condition: int = int(_base_condition * modifier.condition_modifier)

    # If condition changed, we need to scale current_condition proportionally for equipped items
    # This is handled in the apply_modifier method of Equippable
    condition = new_condition

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    var info: Array[AdditionalTooltipInfoData] = super.get_additional_tooltip_info()

    var defense_info := AdditionalTooltipInfoData.new()
    defense_info.text = "🛡️ Defense: +%d%%" % defense_bonus
    defense_info.color = Color(0.6, 0.8, 1.0)  # Light blue color for defense
    info.insert(0, defense_info)  # Insert at beginning so defense shows before enchantment

    # Add resistance information if present
    if has_resistances():
        var resistance_info := AdditionalTooltipInfoData.new()
        var resistance_parts: Array[String] = []
        for damage_type: DamageType.Type in resistances.keys():
            var type_name := DamageType.get_type_name(damage_type)
            resistance_parts.append(type_name)
        resistance_info.text = "🛡️ Resistance: %s" % ", ".join(resistance_parts)
        resistance_info.color = Color(0.9, 0.7, 0.9)  # Light purple for resistances
        info.insert(1, resistance_info)  # Insert after defense

    return info

## Override to get the defense bonus this armor provides
func get_defense_bonus() -> int:
    return defense_bonus

func get_base_inventory_color() -> Color:
    return Color("#6e81a8ff")

## Get resistance for a specific damage type
func get_resistance(damage_type: DamageType.Type) -> bool:
    return resistances.get(damage_type, false)

## Set resistance for a specific damage type
func set_resistance(damage_type: DamageType.Type, has_resistance: bool) -> void:
    if has_resistance:
        resistances[damage_type] = true
    else:
        resistances.erase(damage_type)

## Get all damage types this armor provides resistance to
func get_resistances() -> Dictionary:
    return resistances.duplicate()

## Check if this armor has any resistances
func has_resistances() -> bool:
    return not resistances.is_empty()