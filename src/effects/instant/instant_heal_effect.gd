class_name InstantHealEffect extends StatusEffect

@export var heal_amount: int = 5

func get_effect_id() -> String:
    return "instant_heal"

func get_effect_name() -> String:
    return "Heal"

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_magnitude() -> int:
    return heal_amount

# Override apply_effect to implement instant healing logic
func apply_effect(target: CombatEntity) -> bool:
    # Apply healing to target
    var amount_healed := target.heal(heal_amount)
    if amount_healed > 0:
        # Use application context for better logging if available
        var source_name: String
        if application_context and application_context.log_ability_name:
            source_name = application_context.name
            LogManager.log_event("%s heals {healing:%d}!" % [source_name, amount_healed])
        else:
            LogManager.log_event("Healed {healing:%d}!" % amount_healed)
        return true
    else:
        LogManager.log_event("You are already at full health.")
        return false

# Override get_description for instant heal formatting
func get_description() -> String:
    return "+%d HP" % heal_amount