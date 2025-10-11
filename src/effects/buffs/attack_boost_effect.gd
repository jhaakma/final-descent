class_name AttackBoostEffect extends StatBoostEffect

@export var effect_name: String = "Blessing of Strength"
@export var attack_bonus: int = 3

func get_effect_id() -> String:
    return "attack_boost"


func get_effect_name() -> String:
    return effect_name


func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_description() -> String:
    var stack_text: String = " x%d" % stacks if stacks > 1 else ""
    var total_bonus: int = get_attack_bonus()
    return "+%d ATK (%d turns)%s" % [total_bonus, remaining_turns, stack_text]

# Override to provide the actual attack bonus
func get_attack_bonus() -> int:
    return int(attack_bonus * get_stack_multiplier())