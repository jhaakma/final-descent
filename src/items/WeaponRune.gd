## A WeaponRune is able to enchant the currently equipped weapon with an on-strike enchantment
class_name WeaponRune extends Rune

@export var weapon_enchantment: OnStrikeEnchantment

func get_enchantment() -> Enchantment:
    return weapon_enchantment

func _handles_async_completion() -> bool:
    return true


func _on_use(_item_data: ItemData) -> bool:
    var player := GameState.player

    var available_weapons: Array[ItemInstance] = []
    for weapon_instance: ItemInstance in player.get_item_tiles():
        if weapon_instance.item is Weapon:
            var weapon_item := weapon_instance.item as Weapon
            if weapon_item.enchantment == null:
                available_weapons.append(weapon_instance)

    # Get the enchantment and validate that it's compatible with weapons
    var enchantment := get_enchantment()
    if not enchantment:
        LogManager.log_warning("No enchantment defined for this rune.")
        return false

    # Show selection popup
    GameState.ui_manager.show_weapon_selection_popup(
        available_weapons,
        _on_weapon_selected.bind(enchantment),
        _on_selection_cancelled
    )

    return true

func _on_selection_cancelled() -> void:
    # Signal that the action was cancelled (unsuccessful)
    item_action_completed.emit(false, null)

func _on_weapon_selected(selected_weapon: ItemInstance, enchantment: Enchantment) -> void:
    var weapon := selected_weapon.item as Weapon

    # Validate the enchantment is compatible
    if not weapon.is_valid_enchantment(enchantment):
        LogManager.log_warning("This enchantment cannot be applied to this weapon.")
        # Signal failure
        item_action_completed.emit(false, null)
        return

    var player := GameState.player

    # Remove old enchantment effects if the weapon is equipped
    if player.is_equipped(selected_weapon) and weapon.enchantment:
        if weapon.enchantment is ConstantEffectEnchantment:
            (weapon.enchantment as ConstantEffectEnchantment)._on_weapon_unequipped(weapon)

    # Create new weapon instance
    var enchanted_weapon := weapon.duplicate() as Weapon
    enchanted_weapon.enchantment = enchantment
    enchanted_weapon.name = "%s of %s" % [enchanted_weapon.name, enchantment.get_enchantment_name()]

    if not player.replace_item_instance(selected_weapon, enchanted_weapon):
        LogManager.log_warning("Failed to apply enchantment to weapon.")
        # Signal failure
        item_action_completed.emit(false, null)
        return

    # Apply new enchantment effects if the weapon is equipped
    if player.is_equipped(selected_weapon):
        enchanted_weapon.enchantment.initialise(enchanted_weapon)
        if enchanted_weapon.enchantment is ConstantEffectEnchantment:
            (enchanted_weapon.enchantment as ConstantEffectEnchantment)._on_weapon_equipped(enchanted_weapon)

    LogManager.log_success("You have successfully enchanted your weapon with %s." % enchantment.get_enchantment_name())

    # Signal success
    item_action_completed.emit(true, null)

func get_rune_type_name() -> String:
    return "Imbue Weapon"
