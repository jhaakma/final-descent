class_name DefenseBoostEffect extends StatBoostEffect

@export var defense_bonus: int = 2

func get_effect_id() -> String:
    return "defense_boost"


const CANONICAL_NAME := "+DEF"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_magnitude() -> int:
    return defense_bonus

# Override to provide the actual defense bonus
func get_defense_bonus() -> int:
    return defense_bonus

func get_description() -> String:
    return "+%d DEF for %d turns" % [defense_bonus, get_remaining_turns()]

func get_base_description() -> String:
    return "+%d DEF for %d turns" % [defense_bonus, expire_after_turns]