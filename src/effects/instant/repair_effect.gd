class_name RepairEffect extends StatusEffect

@export var repair_amount: int = 5  # Amount to repair item condition

func apply_effect(target) -> bool:
    var weapon_instance = target.get_equipped_weapon()
    if weapon_instance:
        if weapon_instance.item_data:
            weapon_instance.item_data.current_condition = min(weapon_instance.item_data.current_condition + repair_amount, Item.get_max_condition_for_item(weapon_instance.item))
            LogManager.log_success("Repaired %s's %s by %d points." % [target.name, weapon_instance.item.name, repair_amount])
            return true
        else:
            LogManager.log_warning("%s's equipped weapon is not damaged." % target.name)
            return false
    else:
        var target_name = "You have" if target == GameState.player else "%s has" % target.name
        LogManager.log_warning("%s no weapon equipped to repair." % target_name)
        return false
