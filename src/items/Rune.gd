## A Rune is able to enchant the currently held weapon with the given enchantment
class_name Rune extends Item

@export var enchantment: Enchantment

func get_category() -> Item.ItemCategory:
    return Item.ItemCategory.MISC

func get_consumable() -> bool:
    return true  # Runes are consumable

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

    current_weapon = current_weapon.duplicate() as Weapon
    current_weapon.enchantment = enchantment
    current_weapon.name = "%s of %s" % [current_weapon.name, enchantment.get_enchantment_name()]
    current_weapon_instance.item = current_weapon
    player.equip_weapon(current_weapon_instance)
    LogManager.log_success("You have successfully enchanted your weapon with %s." % enchantment.get_enchantment_name())
    return true

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    if not enchantment:
        return []
    var info := AdditionalTooltipInfoData.new()
    if enchantment:
        info.text = "🔮 Imbue Weapon: %s" % enchantment.get_description()
        info.color = Color(0.8, 0.6, 1.0)
    return [info]
