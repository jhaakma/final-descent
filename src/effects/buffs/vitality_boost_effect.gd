class_name VitalityBoostEffect extends StatBoostEffect

@export var max_hp_bonus: int = 5

func get_effect_id() -> String:
    return "vitality_boost"

const CANONICAL_NAME := "+MAX HP"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Override to provide the actual max HP bonus
func get_max_hp_bonus() -> int:
    return int(max_hp_bonus * get_stack_multiplier())

func get_description() -> String:
    return "+%d Max HP for %d turns" % [max_hp_bonus * get_stack_multiplier(), get_remaining_turns()]

func get_base_description() -> String:
    return "+%d Max HP for %d turns" % [max_hp_bonus, duration]