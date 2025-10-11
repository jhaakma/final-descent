class_name TimedEffect extends StatusEffect

@export var remaining_turns: int = 1  # How many turns this effect lasts
@export var stacks: int = 1  # How many times this effect is applied


# Check if this effect can stack with another effect of the same type
func can_stack_with(other_effect: StatusEffect) -> bool:
    return (get_effect_id() == other_effect.get_effect_id()
        and stacks < get_max_stacks()
    )# Stack this effect with another (add stacks or refresh duration)
func stack_with(other_effect: TimedEffect) -> void:
    if can_stack_with(other_effect):
        stacks = min(stacks + other_effect.stacks, get_max_stacks())
        # Reset duration to incoming effect's duration when stacking
        remaining_turns = other_effect.remaining_turns

func get_max_stacks() -> int:
    return 1  # Default max stacks, can be overridden in subclasses

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
    var stack_text := " x%d" % stacks if stacks > 1 else ""
    return "%s (%d turns)%s" % [get_effect_name(), remaining_turns, stack_text]
