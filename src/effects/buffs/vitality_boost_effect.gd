class_name VitalityBoostEffect extends StatBoostEffect

@export var max_hp_bonus: int = 5

func _init(bonus: int = 5, turns: int = 12) -> void:
    super._init("Blessing of Vitality", turns)
    max_hp_bonus = bonus
    max_stacks = 3  # Allow vitality boost to stack up to 3 times

func get_description() -> String:
    var stack_text: String = " x%d" % stacks if stacks > 1 else ""
    var total_bonus: int = get_max_hp_bonus()
    return "Blessed Vitality: +%d MAX HP (%d turns)%s" % [total_bonus, remaining_turns, stack_text]

# Override to provide the actual max HP bonus
func get_max_hp_bonus() -> int:
    return int(max_hp_bonus * get_stack_multiplier())