class_name ItemPotion extends Item

@export var effect: StatusEffect

func _on_use() -> void:
    if effect:
        # Apply the effect to the player
        GameState.player.apply_status_effect(effect)
    else:
        LogManager.log_warning("Potion has no effect configured!")
