## An ArmorRune is able to enchant a piece of equipped armor with a constant effect enchantment
class_name ArmorRune extends Rune

@export var armor_enchantment: ConstantEffectEnchantment

# Store item data for completion signal
var _current_item_data: ItemData

func get_enchantment() -> Enchantment:
    return armor_enchantment

## Override to indicate this item handles async completion
func _handles_async_completion() -> bool:
    return true

func _on_use(item_data: ItemData) -> bool:
    var player := GameState.player

    # Store item data for later use in completion signal
    _current_item_data = item_data

    # Get all armor pieces in inventory that can be enchanted
    var available_armor: Array[ItemInstance] = []

    for armor_instance: ItemInstance in player.get_item_tiles():
        if armor_instance.item is Armor:
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
    GameState.ui_manager.show_armor_selection_popup(
        available_armor,
        _on_armor_selected.bind(enchantment),
        _on_selection_cancelled
    )

    # Return true to indicate the action started successfully
    # Completion will be signaled later
    return true

func _on_armor_selected(selected_armor: ItemInstance, enchantment: Enchantment) -> void:
    var armor := selected_armor.item as Armor

    # Validate the enchantment is compatible
    if not armor.is_valid_enchantment(enchantment):
        LogManager.log_warning("This enchantment cannot be applied to this armor.")
        # Signal failure
        item_action_completed.emit(false, _current_item_data)
        return

    # Create a unique instance of the armor for enchantment
    var enchanted_armor := armor.duplicate() as Armor
    enchanted_armor.enchantment = enchantment
    enchanted_armor.name = "%s of %s" % [armor.name, enchantment.get_enchantment_name()]

    # Use the reusable replacement method
    var player := GameState.player
    if not player.replace_item_instance(selected_armor, enchanted_armor):
        LogManager.log_warning("Failed to replace armor with enchanted version.")
        item_action_completed.emit(false, _current_item_data)
        return

    LogManager.log_success("You have successfully enchanted your %s with %s." % [enchanted_armor.name, enchantment.get_enchantment_name()])    # Signal successful completion
    item_action_completed.emit(true, _current_item_data)

func _on_selection_cancelled() -> void:
    # Signal that the action was cancelled (unsuccessful)
    item_action_completed.emit(false, _current_item_data)

func get_rune_type_name() -> String:
    return "Imbue Armor"

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
