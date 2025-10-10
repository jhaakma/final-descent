class_name ItemPotion extends Item

@export var status_effect: StatusEffect

func _on_use() -> bool:
    if status_effect:
        # Duplicate the effect to avoid modifying the original resource
        var effect_copy = status_effect.duplicate()
        GameState.player.apply_status_effect(effect_copy)

    else:
        LogManager.log_warning("Potion has no effect configured!")
    return true