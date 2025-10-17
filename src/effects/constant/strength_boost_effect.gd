class_name StrengthBoostEffect extends ConstantEffect

@export var strength_bonus: int = 3

func get_effect_id() -> String:
    return "strength_boost"

func get_effect_name() -> String:
    return "Strength Boost"

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Called when the effect is first applied to an entity
func on_applied(target: CombatEntity) -> void:
    if target.has_method("add_stat_modifier"):
        target.call("add_stat_modifier", "strength", strength_bonus)
    # Note: This doesn't seem like healing, but keeping green color for positive effect
    LogManager.log_event("{Your} strength increases by {bonus:+%d}!" % strength_bonus, {"target": target})

# Called when the effect is removed from an entity
func on_removed(target: CombatEntity) -> void:
    if target.has_method("remove_stat_modifier"):
        target.call("remove_stat_modifier", "strength", strength_bonus)

# Override get_description for strength boost formatting
func get_description() -> String:
    return "Strength +%d" % strength_bonus

func get_base_description() -> String:
    if is_permanent():
        return "Strength +%d (permanent)" % strength_bonus
    else:
        return "Strength +%d (constant)" % strength_bonus