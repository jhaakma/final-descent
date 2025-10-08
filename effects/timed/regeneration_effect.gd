class_name RegenerationEffect extends TimedEffect

@export var healing_per_turn: int = 2

func _init(healing: int = 2, turns: int = 3)->void:
    super._init("Regeneration", turns)
    healing_per_turn = healing
    effect_type = EffectType.POSITIVE
    max_stacks = 5  # Allow regeneration to stack up to 5 times

# Override apply_effect to implement healing logic
func apply_effect(target: CombatEntity) -> bool:
    var total_healing := int(healing_per_turn * get_stack_multiplier())

    # Apply healing to target
    target.heal(total_healing)

    # Use enhanced logging with target context
    LogManager.log_status_effect_healing(target, effect_name, total_healing)

    return true

# Override get_description for regeneration-specific formatting
func get_description() -> String:
    var stack_text := " x%d" % stacks if stacks > 1 else ""
    var total_healing := int(healing_per_turn * get_stack_multiplier())
    return "Regenerating (%d heal, %d turns)%s" % [total_healing, remaining_turns, stack_text]