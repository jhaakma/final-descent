class_name DefenseBoostEffect extends StatBoostEffect

@export var defense_bonus: int = 2

func get_effect_id() -> String:
    return "defense_boost"


const CANONICAL_NAME := "+DEF"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_description() -> String:
    var stack_text: String = " x%d" % stacks if stacks > 1 else ""
    var total_bonus: int = get_defense_bonus()
    return "+%d DEF (%d turns)%s" % [total_bonus, remaining_turns, stack_text]

# Override to provide the actual defense bonus
func get_defense_bonus() -> int:
    return int(defense_bonus * get_stack_multiplier())