class_name PoisonEffect extends TimedEffect

@export var damage_per_turn: int = 2

func get_effect_name() -> String:
    return "Poison"

func get_effect_type() -> EffectType:
    return EffectType.NEGATIVE

# Allow up to 5 stacks of poison
func get_max_stacks() -> int:
    return 5

# Override apply_effect to implement poison damage logic
func apply_effect(target: CombatEntity) -> bool:
    var total_damage := int(damage_per_turn * get_stack_multiplier())

    # Apply damage to target
    target.take_damage(total_damage)

    # Use enhanced logging with target context
    LogManager.log_status_effect_damage(target, get_effect_name(), total_damage)

    return true

# Override get_description for better poison-specific formatting
func get_description() -> String:
    var stack_text := " x%d" % stacks if stacks > 1 else ""
    var total_dmg := int(damage_per_turn * get_stack_multiplier())
    return "%s (%d dmg, %d turns)%s" % [get_effect_name(), total_dmg, remaining_turns, stack_text]