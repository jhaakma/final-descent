@tool
extends InflictingWeapon

func _init() -> void:
    super._init()
    name = "Stunning Sword"
    description = "A sword that can stun enemies on hit."
    damage = 4
    condition = 100
    purchase_value = 25

    # Create a stun effect that lasts 2 turns
    status_effect = StunEffect.new(2)
    effect_apply_chance = 0.5  # 50% chance to stun