## An ArmorRune is able to enchant a piece of equipped armor with a constant effect enchantment
class_name ArmorRune extends Rune

@export var armor_enchantment: ConstantEffectEnchantment
## Specifies which armor slot this rune can enchant
@export var target_slot: Equippable.EquipSlot = Equippable.EquipSlot.CUIRASS

func get_enchantment() -> Enchantment:
    return armor_enchantment

func _on_use(_item_data: ItemData) -> bool:
    var player := GameState.player

    # Get all equipped armor pieces that can be enchanted
    var available_armor: Array[ItemInstance] = []

    # Check all armor slots for equipped items that can be enchanted
    var all_armor_slots := [
        Equippable.EquipSlot.HELMET,
        Equippable.EquipSlot.CUIRASS,
        Equippable.EquipSlot.GLOVES,
        Equippable.EquipSlot.BOOTS,
        Equippable.EquipSlot.SHIELD
    ]

    for slot: Equippable.EquipSlot in all_armor_slots:
        var armor_instance := player.get_equipped_armor(slot)
        if armor_instance:
            var armor := armor_instance.item as Armor
            # Only add armor that doesn't already have an enchantment
            if not armor.enchantment:
                available_armor.append(armor_instance)

    # Check if we have any armor to enchant
    if available_armor.is_empty():
        LogManager.log_warning("No unenchanted armor equipped to enchant.")
        return false

    # Get the enchantment and validate it exists
    var enchantment := get_enchantment()
    if not enchantment:
        LogManager.log_warning("No enchantment defined for this rune.")
        return false

    # Show selection popup
    GameState.ui_manager.show_armor_selection_popup(available_armor, _on_armor_selected.bind(enchantment))
    return true

func _on_armor_selected(enchantment: Enchantment, selected_armor: ItemInstance) -> void:
    var armor := selected_armor.item as Armor

    # Validate the enchantment is compatible
    if not armor.is_valid_enchantment(enchantment):
        LogManager.log_warning("This enchantment cannot be applied to this armor.")
        return

    # Duplicate the armor and apply enchantment
    armor = armor.duplicate() as Armor
    armor.enchantment = enchantment
    armor.name = "%s of %s" % [armor.name, enchantment.get_enchantment_name()]
    selected_armor.item = armor

    # Re-equip the armor to update the player's equipment
    GameState.player.equip_armor(selected_armor)

    LogManager.log_success("You have successfully enchanted your %s with %s." % [armor.name, enchantment.get_enchantment_name()])

func get_rune_type_name() -> String:
    var slot_name := _get_slot_name(target_slot)
    return "Imbue %s" % slot_name

func _get_slot_name(slot: Equippable.EquipSlot) -> String:
    match slot:
        Equippable.EquipSlot.HELMET:
            return "Helmet"
        Equippable.EquipSlot.CUIRASS:
            return "Cuirass"
        Equippable.EquipSlot.GLOVES:
            return "Gloves"
        Equippable.EquipSlot.BOOTS:
            return "Boots"
        Equippable.EquipSlot.SHIELD:
            return "Shield"
        _:
            return "Armor"