class_name RegenerationEffect extends TimedEffect

@export var healing_per_turn: int = 2

func get_effect_id() -> String:
    return "regeneration"

func get_effect_name() -> String:
    return "Regeneration"

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Override apply_effect to implement healing logic
func apply_effect(target: CombatEntity) -> bool:
    var total_healing := int(healing_per_turn * get_stack_multiplier())

    # Apply healing to target
    target.heal(total_healing)

    # Use enhanced logging with target context
    LogManager.log_status_effect_healing(target, get_effect_name(), total_healing)

    return true

