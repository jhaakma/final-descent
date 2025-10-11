class_name ItemPotion extends Item

@export var status_effect: StatusEffect
@export var log_potion_name: bool = false

func get_consumable() -> bool:
    return true

func _on_use(_item_data: ItemData) -> bool:
    # Duplicate the effect to avoid modifying the original resource
    var condition := StatusCondition.new()
    condition.name = name
    condition.status_effect = status_effect.duplicate()
    condition.log_ability_name = log_potion_name
    return GameState.player.apply_status_condition(condition)
