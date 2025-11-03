class_name DefendEffect extends StatBoostEffect

@export var defense_bonus: int = 50

func _init(defense_value: int = 50) -> void:
    defense_bonus = defense_value
    # Use new timing system: expire after taking one attack (POST_ACTION timing)
    expire_timing = EffectTiming.Type.ROUND_END
    expire_after_turns = 1

func get_effect_id() -> String:
    return "defend"

const CANONICAL_NAME := "Defending"

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
    return "+%d DEF for %d turns (defending)" % [defense_bonus, get_remaining_turns()]

func get_base_description() -> String:
    return "+%d DEF for %d turns (defending)" % [defense_bonus, expire_after_turns]
