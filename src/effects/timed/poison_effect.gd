class_name PoisonEffect extends TimedEffect

@export var damage_per_turn: int = 2

func get_effect_name() -> String:
    return "Poison"

func get_effect_type() -> EffectType:
    return EffectType.NEGATIVE

# Override apply_effect to implement poison damage logic
func apply_effect(target: CombatEntity) -> bool:
    # Apply damage to target
    target.take_damage(damage_per_turn)

    # Use enhanced logging with target context
    LogManager.log_status_effect_damage(target, get_effect_name(), damage_per_turn)

    return true

func get_base_description() -> String:
    return "%d %s damage for %d turns" % [damage_per_turn, get_effect_name(), duration]