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

func get_description() -> String:
    return "Stunned for %d turns" % expire_after_turns

func get_base_description() -> String:
    return "Stunned for %d turns" % expire_after_turns
