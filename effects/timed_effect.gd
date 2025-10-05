class_name TimedEffect extends StatusEffect

@export var remaining_turns: int = 1  # How many turns this effect lasts
@export var stacks: int = 1  # How many times this effect is applied
@export var max_stacks: int = 1  # Maximum stacks allowed

func _init(name: String = "", turns: int = 1):
    super._init(name)
    remaining_turns = turns

# Check if this effect can stack with another effect of the same type
func can_stack_with(other_effect: StatusEffect) -> bool:
    return effect_name == other_effect.effect_name and stacks < max_stacks

# Stack this effect with another (add stacks or refresh duration)
func stack_with(other_effect: StatusEffect) -> void:
    if can_stack_with(other_effect):
        stacks = min(stacks + other_effect.stacks, max_stacks)


# Get the total magnitude of the effect based on stacks
func get_stack_multiplier() -> float:
    return float(stacks)

# Decrease remaining turns by 1
func tick_turn() -> void:
    remaining_turns -= 1

# Check if effect has expired
func is_expired() -> bool:
    return remaining_turns <= 0

# Get descriptive text for UI
func get_description() -> String:
    var stack_text = " x%d" % stacks if stacks > 1 else ""
    return "%s (%d turns)%s" % [effect_name, remaining_turns, stack_text]
