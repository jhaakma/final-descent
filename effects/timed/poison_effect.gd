class_name PoisonEffect extends TimedEffect

@export var damage_per_turn: int = 2

func _init(dmg: int = 2, turns: int = 3):
    super._init("Poison", turns)
    damage_per_turn = dmg
    effect_color = EffectColor.NEGATIVE
    max_stacks = 3  # Allow poison to stack up to 3 times

# Override apply_effect to implement poison damage logic
func apply_effect(target) -> StatusEffectResult:
    var total_damage = int(damage_per_turn * get_stack_multiplier())

    # Apply damage to target
    target.take_damage(total_damage)

    # Log the poison damage with appropriate color
    LogManager.log_poison("Takes %d poison damage!" % total_damage)

    return StatusEffectResult.new(
        effect_name,
        ""  # Empty message since we already logged it with proper color
    )

# Override get_description for better poison-specific formatting
func get_description() -> String:
    var stack_text = " x%d" % stacks if stacks > 1 else ""
    var total_dmg = int(damage_per_turn * get_stack_multiplier())
    return "Poisoned (%d dmg, %d turns)%s" % [total_dmg, remaining_turns, stack_text]