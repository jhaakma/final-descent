@tool
extends ItemPotion

func _init() -> void:
    name = "Stunning Grenade"
    description = "A throwable item that stuns yourself for 3 turns (for testing)."
    purchase_value = 15

    # Create a stun effect that lasts 3 turns
    status_effect = StunEffect.new(3)

func _on_use() -> bool:
    # Apply stun effect to the player for testing purposes
    LogManager.log_combat("You throw the stunning grenade and accidentally stun yourself!")
    return super._on_use()  # This will apply the status_effect to the player