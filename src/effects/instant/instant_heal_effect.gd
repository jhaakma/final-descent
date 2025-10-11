class_name InstantHealEffect extends StatusEffect

@export var heal_amount: int = 5

func get_effect_id() -> String:
    return "instant_heal"

func get_effect_name() -> String:
    return "Heal"

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Override apply_effect to implement instant healing logic
func apply_effect(target: CombatEntity) -> bool:
    # Apply healing to target
    var amount_healed := target.heal(heal_amount)
    if amount_healed > 0:
        # Log the healing effect
        LogManager.log_healing("Healed %d HP!" % amount_healed)
        return true
    else:
        LogManager.log_warning("You are already at full health.")
        return false

# Override get_description for instant heal formatting
func get_description() -> String:
    return "Heal (%d HP)" % heal_amount