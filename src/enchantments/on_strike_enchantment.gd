class_name OnStrikeEnchantment extends Enchantment

## Called when the weapon hits a target
func on_strike(_target: CombatEntity) -> void:
    # This method should be overridden in subclasses to define specific behavior
    print_debug("OnStrikeEnchantment.on_strike() should be overridden in subclasses.")


func initialise(_owner: Object) -> void:
    if is_valid_owner(_owner):
        (_owner as Weapon).attack_hit.connect(on_strike)
    else:
        print_debug("Warning: Enchantment %s cannot be applied to %s" % [
            self.get_class(),
            _owner.get_class()
        ])


func is_valid_owner(_owner: Object) -> bool:
    return _owner.has_signal("attack_hit")