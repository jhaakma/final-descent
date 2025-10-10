class_name RepairTool extends Item

@export var repair_amount: int = 5  # Amount to repair item condition

func _on_use() -> bool:
    var repair_effect := RepairEffect.new()
    repair_effect.repair_amount = repair_amount
    return repair_effect.apply_effect(GameState.player)

func get_description() -> String:
    return "Repairs %d condition to the equipped weapon." % [repair_amount]
