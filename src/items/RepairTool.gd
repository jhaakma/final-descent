class_name RepairTool extends Item

@export var repair_amount: int = 5  # Amount to repair item condition

func _on_use(_item_data: ItemData) -> bool:
    var repair_effect := RepairEffect.new()
    repair_effect.repair_amount = repair_amount
    var result := GameState.player.apply_status_effect(repair_effect)
    return result

func get_description() -> String:
    return "Repairs %d condition to the equipped weapon." % [repair_amount]
