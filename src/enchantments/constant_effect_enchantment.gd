class_name ConstantEffectEnchantment extends Enchantment

@export var constant_effect: ConstantEffect
@export var auto_remove_on_unequip: bool = true  # Remove effect when item is unequipped

func get_enchantment_name() -> String:
    if constant_effect:
        return constant_effect.get_effect_name()
    return "Constant Effect"

func get_description() -> String:
    if constant_effect:
        return "While equipped: %s" % constant_effect.get_base_description()
    return "Provides a constant effect while equipped."

func initialise(_owner: Object) -> void:
    # Store reference but don't apply effect yet - this will be called by Player when equipped
    pass

func _on_weapon_equipped(_weapon: Weapon) -> void:
    # Apply the constant effect when the weapon is equipped
    _apply_effect()

func _on_weapon_unequipped(_weapon: Weapon) -> void:
    # Remove the constant effect when the weapon is unequipped
    _remove_effect()

func _on_item_equipped(_item: Equippable) -> void:
    # Apply the constant effect when any equippable item is equipped
    _apply_effect()

func _on_item_unequipped(_item: Equippable) -> void:
    # Remove the constant effect when any equippable item is unequipped
    _remove_effect()

func _apply_effect() -> void:
    if constant_effect:
        var player := GameState.player
        if player and player.has_method("apply_status_condition"):
            # Create an equipment-based condition that can stack
            var condition := StatusCondition.from_equipment_effect(constant_effect)
            player.apply_status_condition(condition)

func _remove_effect() -> void:
    if auto_remove_on_unequip and constant_effect:
        var player := GameState.player
        if player and player.has_method("remove_equipment_stack"):
            player.remove_equipment_stack(constant_effect)
        elif player and player.has_method("remove_status_effect"):
            # Fallback for non-equipment effects
            player.remove_status_effect(constant_effect)

func on_unequip() -> void:
    # Fallback method in case the signal approach doesn't work
    if auto_remove_on_unequip and constant_effect:
        var player := GameState.player
        if player and player.has_method("remove_equipment_stack"):
            player.remove_equipment_stack(constant_effect)
        elif player and player.has_method("remove_status_effect"):
            # Fallback for non-equipment effects
            player.remove_status_effect(constant_effect)

func is_valid_owner(owner: Object) -> bool:
    # Constant effect enchantments can only be applied to armor, not weapons
    # Weapons should use on-strike enchantments instead
    return owner is Armor
