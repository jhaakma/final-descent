class_name AttackBoostEffect extends StatBoostEffect

@export var attack_bonus: int = 3

func get_effect_id() -> String:
    return "attack_boost"

const CANONICAL_NAME := "+ATK"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE


# Override to provide the actual attack bonus
func get_attack_bonus() -> int:
    return int(attack_bonus * get_stack_multiplier())

func get_description() -> String:
    return "+%d ATK for %d turns" % [attack_bonus * get_stack_multiplier(), get_remaining_turns()]

func get_base_description() -> String:
    return "+%d ATK for %d turns" % [attack_bonus, duration]
