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

# Override to provide attack bonus
func get_attack_bonus() -> int:
    return int(attack_bonus * get_stack_multiplier())

# Override to provide defense bonus
func get_defense_bonus() -> int:
    return int(defense_bonus * get_stack_multiplier())

func get_description() -> String:
    var stack_mult := get_stack_multiplier()
    return "+%d ATK, +%d DEF for %d turns" % [attack_bonus * stack_mult, defense_bonus * stack_mult, get_remaining_turns()]

func get_base_description() -> String:
    return "+%d ATK, +%d DEF for %d turns" % [attack_bonus, defense_bonus, duration]