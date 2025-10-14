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
        target.add_stat_modifier("strength", strength_bonus)
    LogManager.log_status_effect_healing(target, get_effect_name(), strength_bonus)

# Called when the effect is removed from an entity
func on_removed(target: CombatEntity) -> void:
    if target.has_method("remove_stat_modifier"):
        target.remove_stat_modifier("strength", strength_bonus)

# Override get_description for strength boost formatting
func get_description() -> String:
    return "Strength +%d" % strength_bonus

func get_base_description() -> String:
    if is_permanent():
        return "Strength +%d (permanent)" % strength_bonus
    else:
        return "Strength +%d (constant)" % strength_bonus