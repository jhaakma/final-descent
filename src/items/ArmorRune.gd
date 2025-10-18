## An ArmorRune is able to enchant a piece of equipped armor with a constant effect enchantment
class_name ArmorRune extends Rune

@export var armor_enchantment: ConstantEffectEnchantment
## Specifies which armor slot this rune can enchant
@export var target_slot: Equippable.EquipSlot = Equippable.EquipSlot.CUIRASS

func get_enchantment() -> Enchantment:
    return armor_enchantment

func _on_use(_item_data: ItemData) -> bool:
    var player := GameState.player
    var current_armor_instance := player.get_equipped_armor(target_slot)
    if not current_armor_instance:
        var slot_name := _get_slot_name(target_slot)
        LogManager.log_warning("No %s equipped to enchant." % slot_name.to_lower())
        return false

    var current_armor := current_armor_instance.item as Armor
    if current_armor.enchantment:
        LogManager.log_warning("Current %s already has an enchantment." % _get_slot_name(target_slot).to_lower())
        return false

    # Get the enchantment and validate that it's compatible with armor
    var enchantment := get_enchantment()
    if not enchantment:
        LogManager.log_warning("No enchantment defined for this rune.")
        return false

    if not current_armor.is_valid_enchantment(enchantment):
        LogManager.log_warning("This enchantment cannot be applied to armor.")
        return false

    # Duplicate the armor and apply enchantment
    current_armor = current_armor.duplicate() as Armor
    current_armor.enchantment = enchantment
    current_armor.name = "%s of %s" % [current_armor.name, enchantment.get_enchantment_name()]
    current_armor_instance.item = current_armor
    player.equip_armor(current_armor_instance)
    LogManager.log_success("You have successfully enchanted your %s with %s." % [_get_slot_name(target_slot).to_lower(), enchantment.get_enchantment_name()])
    return true

func get_rune_type_name() -> String:
    var slot_name := _get_slot_name(target_slot)
    return "Imbue %s" % slot_name

func _get_slot_name(slot: Equippable.EquipSlot) -> String:
    match slot:
        Equippable.EquipSlot.CUIRASS:
            return "Cuirass"
        Equippable.EquipSlot.SHIELD:
            return "Shield"
        _:
            return "Armor"