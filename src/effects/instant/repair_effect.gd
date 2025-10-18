class_name RepairEffect extends StatusEffect

@export var repair_amount: int = 5  # Amount to repair item condition

func get_effect_id() -> String:
    return "repair"

func get_effect_name() -> String:
    return "Repair"

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_magnitude() -> int:
    return repair_amount

func can_apply(target: CombatEntity) -> bool:
    if not target is Player:
        return false  # Only players can have items repaired
    var player := target as Player

    # Check if any equipped item can be repaired
    var all_equipped := player.get_all_equipped_items()
    for item_instance: ItemInstance in all_equipped:
        if item_instance.item_data and item_instance.item is Equippable:
            var equippable := item_instance.item as Equippable
            var current_condition := item_instance.item_data.current_condition
            var max_condition := equippable.get_max_condition()
            if current_condition < max_condition:
                return true  # Found at least one item that can be repaired

    return false  # No damaged items found

func apply_effect(target: CombatEntity) -> bool:
    if not target is Player:
        return false  # Only players can have items repaired

    # This method will be called after item selection in the popup
    # For now, return false as the repair will be handled by the RepairTool directly
    LogManager.log_event("Use item selection to repair specific items.")
    return false

func get_description() -> String:
    return "+%d condition" % repair_amount
