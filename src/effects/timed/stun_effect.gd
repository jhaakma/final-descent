class_name StunEffect extends TimedEffect

func get_effect_id() -> String:
    return "stun"

func get_effect_name() -> String:
    return "Stun"

func get_effect_type() -> EffectType:
    return EffectType.NEGATIVE

# Override apply_effect to implement stun logic
func apply_effect(_target: CombatEntity) -> bool:
    # Stun effect: the entity will skip turns while this effect is active
    # The should_skip_turn() method will check for active stun effect

    # The status effect logging is handled by the StatusEffectComponent
    # when the effect is first applied, so we don't need to log here

    return true

# Override get_description for better stun-specific formatting
func get_description() -> String:
    var stack_text := " x%d" % stacks if stacks > 1 else ""
    return "Stunned (%d turns)%s" % [remaining_turns, stack_text]
