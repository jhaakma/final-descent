class_name VitalityBoostEffect extends StatBoostEffect

@export var max_hp_bonus: int = 5

func get_effect_id() -> String:
    return "vitality_boost"


const CANONICAL_NAME := "+MAX HP"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_description() -> String:
    var stack_text: String = " x%d" % stacks if stacks > 1 else ""
    var total_bonus: int = get_max_hp_bonus()
    return "+%d MAX HP (%d turns)%s" % [total_bonus, remaining_turns, stack_text]

# Override to provide the actual max HP bonus
func get_max_hp_bonus() -> int:
    return int(max_hp_bonus * get_stack_multiplier())