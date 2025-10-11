class_name BalancedBoostEffect extends StatBoostEffect

@export var attack_bonus: int = 2
@export var defense_bonus: int = 1

func get_effect_id() -> String:
    return "balanced_boost"

const CANONICAL_NAME := "+ATK/DEF"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE


func get_description() -> String:
    var stack_text: String = " x%d" % stacks if stacks > 1 else ""
    var total_atk_bonus: int = get_attack_bonus()
    var total_def_bonus: int = get_defense_bonus()
    return "+%d ATK, +%d DEF (%d turns)%s" % [total_atk_bonus, total_def_bonus, remaining_turns, stack_text]

# Override to provide attack bonus
func get_attack_bonus() -> int:
    return int(attack_bonus * get_stack_multiplier())

# Override to provide defense bonus
func get_defense_bonus() -> int:
    return int(defense_bonus * get_stack_multiplier())