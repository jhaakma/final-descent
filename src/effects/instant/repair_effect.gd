class_name RepairEffect extends StatusEffect

@export var repair_amount: int = 5  # Amount to repair item condition

func get_effect_id() -> String:
    return "repair"

func get_effect_name() -> String:
    return "Repair"

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func can_apply(target: CombatEntity) -> bool:
    if not target is Player:
        return false  # Only players can have items repaired
    var player := target as Player
    var weapon_instance := player.get_equipped_weapon()
    if weapon_instance:
        if weapon_instance.item_data:
            var current_condition := weapon_instance.item_data.current_condition
            var max_condition := (weapon_instance.item as Weapon).get_max_condition()
            return current_condition < max_condition  # Can apply if weapon is damaged
        else:
            return false  # No item data means nothing to repair
    else:
        return false  # No weapon equipped

func apply_effect(target: CombatEntity) -> bool:
    if not target is Player:
        return false  # Only players can have items repaired
    var player := target as Player
    var weapon_instance := player.get_equipped_weapon()
    if weapon_instance:
        if weapon_instance.item_data:
            var current_condition := weapon_instance.item_data.current_condition
            var max_condition := (weapon_instance.item as Weapon).get_max_condition()
            weapon_instance.item_data.current_condition = min(current_condition + repair_amount, max_condition)
            weapon_instance.item_data_updated()
            LogManager.log_success("Repaired %s by %d points" % [weapon_instance.item.name, repair_amount])
            return true
        else:
            LogManager.log_warning("Your equipped weapon is not damaged.")
            return false
    else:
        LogManager.log_warning("You have no weapon equipped to repair.")
        return false

func get_description() -> String:
    return "Repairs %d condition to the equipped weapon." % repair_amount
