class_name DefenseBoostEffect extends StatBoostEffect

@export var defense_bonus: int = 2

func _init(bonus: int = 2, turns: int = 10) -> void:
    super._init("Blessing of Protection", turns)
    defense_bonus = bonus
    max_stacks = 3  # Allow defense boost to stack up to 3 times

func get_description() -> String:
    var stack_text: String = " x%d" % stacks if stacks > 1 else ""
    var total_bonus: int = get_defense_bonus()
    return "Divine Protection: +%d DEF (%d turns)%s" % [total_bonus, remaining_turns, stack_text]

# Override to provide the actual defense bonus
func get_defense_bonus() -> int:
    return int(defense_bonus * get_stack_multiplier())