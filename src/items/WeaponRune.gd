## A WeaponRune is able to enchant the currently equipped weapon with an on-strike enchantment
class_name WeaponRune extends Rune

@export var weapon_enchantment: OnStrikeEnchantment

func get_enchantment() -> Enchantment:
    return weapon_enchantment

func _on_use(_item_data: ItemData) -> bool:
    var player := GameState.player
    var current_weapon_instance := player.get_equipped_weapon()
    if not current_weapon_instance:
        LogManager.log_warning("No weapon equipped to enchant.")
        return false

    var current_weapon := current_weapon_instance.item as Weapon
    if current_weapon.enchantment:
        LogManager.log_warning("Current weapon already has an enchantment.")
        return false

    # Get the enchantment and validate that it's compatible with weapons
    var enchantment := get_enchantment()
    if not enchantment:
        LogManager.log_warning("No enchantment defined for this rune.")
        return false

    if not current_weapon.is_valid_enchantment(enchantment):
        LogManager.log_warning("This enchantment cannot be applied to weapons.")
        return false

    # Duplicate the weapon and apply enchantment
    current_weapon = current_weapon.duplicate() as Weapon
    current_weapon.enchantment = enchantment
    current_weapon.name = "%s of %s" % [current_weapon.name, enchantment.get_enchantment_name()]
    current_weapon_instance.item = current_weapon
    player.equip_weapon(current_weapon_instance)
    LogManager.log_success("You have successfully enchanted your weapon with %s." % enchantment.get_enchantment_name())
    return true

func get_rune_type_name() -> String:
    return "Imbue Weapon"