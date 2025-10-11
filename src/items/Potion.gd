class_name ItemPotion extends Item

@export var status_effect: StatusEffect

func get_consumable() -> bool:
    return true

func _on_use(_item_data: ItemData) -> bool:
    # Duplicate the effect to avoid modifying the original resource
    var effect_copy: StatusEffect = status_effect.duplicate()
    return GameState.player.apply_status_effect(effect_copy)
