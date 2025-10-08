class_name BalancedBoostEffect extends StatBoostEffect

@export var attack_bonus: int = 2
@export var defense_bonus: int = 1

func _init(atk_bonus: int = 2, def_bonus: int = 1, turns: int = 6) -> void:
    super._init("Blessing of Balance", turns)
    attack_bonus = atk_bonus
    defense_bonus = def_bonus
    max_stacks = 3  # Allow balanced boost to stack up to 3 times

func get_description() -> String:
    var stack_text: String = " x%d" % stacks if stacks > 1 else ""
    var total_atk_bonus: int = get_attack_bonus()
    var total_def_bonus: int = get_defense_bonus()
    return "Blessed Balance: +%d ATK, +%d DEF (%d turns)%s" % [total_atk_bonus, total_def_bonus, remaining_turns, stack_text]

# Override to provide attack bonus
func get_attack_bonus() -> int:
    return int(attack_bonus * get_stack_multiplier())

# Override to provide defense bonus
func get_defense_bonus() -> int:
    return int(defense_bonus * get_stack_multiplier())