class_name Equippable extends Item

signal equip(equippable: Equippable)
signal unequip(equippable: Equippable)

@export var condition: int = 10  # Base condition when new
@export var enchantment: Enchantment:
    set = set_enchantment
@export var modifier: EquipmentModifier:
    set = set_modifier

var _base_name: String = ""  # Store original name before modifier is applied

enum EquipSlot {
    WEAPON,
    HELMET,   # Head armor
    CUIRASS,  # Chest armor
    GLOVES,   # Hand armor
    BOOTS,    # Foot armor
    SHIELD    # Shield slot
}

func _init() -> void:
    name = "Equippable"

## Virtual method to determine the equipment slot - must be overridden
func get_equip_slot() -> EquipSlot:
    push_error("get_equip_slot() must be overridden in Equippable subclasses")
    return EquipSlot.WEAPON

## Virtual method to check if an enchantment is valid for this item type
func is_valid_enchantment(_enchant: Enchantment) -> bool:
    push_error("is_valid_enchantment() must be overridden in Equippable subclasses")
    return false

func set_enchantment(_enchantment: Enchantment) -> void:
    if not _enchantment:
        enchantment = null
        return

    if not is_valid_enchantment(_enchantment):
        push_error("Warning: Enchantment %s is not valid for %s" % [_enchantment.get_class(), get_class()])
        enchantment = null
        return

    enchantment = _enchantment
    if _enchantment.is_valid_owner(self):
        _enchantment.initialise(self)
    else:
        push_error("Warning: Enchantment %s is not valid owner for %s" % [_enchantment.get_class(), get_class()])

func set_modifier(_modifier: EquipmentModifier) -> void:
    if not _modifier:
        modifier = null
        return

    if not _modifier.can_apply_to(self):
        push_error("Warning: Modifier %s is not valid for %s" % [_modifier.modifier_name, name])
        modifier = null
        return

    modifier = _modifier
    _apply_modifier_to_stats()

## Check if this item can have a modifier applied
func can_have_modifier() -> bool:
    # Items can only have one modifier
    return modifier == null

## Apply a modifier to this item (returns true if successful)
func apply_modifier(new_modifier: EquipmentModifier) -> bool:
    if not can_have_modifier():
        return false

    if not new_modifier.can_apply_to(self):
        return false

    modifier = new_modifier
    _apply_modifier_to_stats()
    return true

## Internal method to apply modifier stat changes
func _apply_modifier_to_stats() -> void:
    if not modifier:
        return

    # Store base name if not already stored
    if _base_name == "":
        _base_name = name

    # Apply modifier prefix/suffix to base name
    name = modifier.get_modified_name(_base_name)

func get_consumable() -> bool:
    return false  # Equippable items are not consumable

func _on_use(item_data: ItemData) -> bool:
    return GameState.player.equip_item(ItemInstance.new(self, item_data, 1))

func on_equip() -> void:
    equip.emit(self)

func on_unequip() -> void:
    unequip.emit(self)

func get_max_condition() -> int:
    return condition

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

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    var info: Array[AdditionalTooltipInfoData] = []

    if modifier:
        var modifier_info := AdditionalTooltipInfoData.new()
        modifier_info.text = "⚒️ %s (%s)" % [modifier.modifier_name, modifier.get_description()]
        modifier_info.color = Color(1.0, 0.85, 0.4)  # Golden color for modifiers
        info.append(modifier_info)

    if enchantment:
        var enchantment_info := AdditionalTooltipInfoData.new()
        enchantment_info.text = "🔮 Enchantment: %s" % enchantment.get_description()
        enchantment_info.color = Color(0.8, 0.6, 1.0)
        info.append(enchantment_info)

    return info

func get_inventory_color() -> Color:
    if enchantment:
        return Color("#ac6ad8ff")  # Light purple for enchanted items
    if modifier:
        return Color("#ffd966ff")  # Golden for modified items
    return get_base_inventory_color()

func get_base_inventory_color() -> Color:
    return Color("#949494ff")

## Get the equipment slot name as a string for UI display
func get_equip_slot_name() -> String:
    match get_equip_slot():
        EquipSlot.WEAPON:
            return "Weapon"
        EquipSlot.HELMET:
            return "Helmet"
        EquipSlot.CUIRASS:
            return "Cuirass"
        EquipSlot.GLOVES:
            return "Gloves"
        EquipSlot.BOOTS:
            return "Boots"
        EquipSlot.SHIELD:
            return "Shield"
        _:
            return "Unknown"
