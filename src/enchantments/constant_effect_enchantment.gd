class_name ConstantEffectEnchantment extends Enchantment

@export var constant_effect: ConstantEffect
@export var auto_remove_on_unequip: bool = true  # Remove effect when item is unequipped

var _applied_target: CombatEntity = null

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
        if player and player.has_method("apply_status_effect"):
            player.apply_status_effect(constant_effect)
            _applied_target = player

func _remove_effect() -> void:
    if auto_remove_on_unequip and _applied_target and constant_effect:
        if _applied_target.has_method("remove_status_effect"):
            _applied_target.remove_status_effect(constant_effect)
        _applied_target = null

func on_unequip() -> void:
    # Fallback method in case the signal approach doesn't work
    if auto_remove_on_unequip and _applied_target and constant_effect:
        if _applied_target.has_method("remove_status_effect"):
            _applied_target.remove_status_effect(constant_effect)
        _applied_target = null

func is_valid_owner(owner: Object) -> bool:
    # Constant effect enchantments can only be applied to armor, not weapons
    # Weapons should use on-strike enchantments instead
    return owner is Armor