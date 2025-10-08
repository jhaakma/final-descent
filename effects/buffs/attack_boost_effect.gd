class_name AttackBoostEffect extends StatBoostEffect

@export var attack_bonus: int = 3

func _init(bonus: int = 3, turns: int = 8) -> void:
    super._init("Blessing of Strength", turns)
    attack_bonus = bonus
    max_stacks = 3  # Allow attack boost to stack up to 3 times

func get_description() -> String:
    var stack_text: String = " x%d" % stacks if stacks > 1 else ""
    var total_bonus: int = get_attack_bonus()
    return "Blessed Strength: +%d ATK (%d turns)%s" % [total_bonus, remaining_turns, stack_text]

# Override to provide the actual attack bonus
func get_attack_bonus() -> int:
    return int(attack_bonus * get_stack_multiplier())