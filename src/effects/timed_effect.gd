class_name TimedEffect extends StatusEffect

@export var duration: int = 1  # How many turns this effect lasts
var stack_durations: Array[int] = []

# Check if this effect can stack with another effect of the same type
func can_stack_with(other_effect: StatusEffect) -> bool:
    return get_effect_id() == other_effect.get_effect_id() and stack_durations.size() < get_max_stacks()

# Stack this effect with another (add stacks or refresh duration)
func stack_with(other_effect: TimedEffect) -> void:
    if can_stack_with(other_effect):
        stack_durations.append(other_effect.get_duration())
        stack_durations = stack_durations.slice(0, get_max_stacks())

func get_max_stacks() -> int:
    return 1 # Example, override as needed

# Get the total magnitude of the effect based on stacks
func get_stack_multiplier() -> float:
    return float(stack_durations.size())

# Decrease remaining turns by 1
func tick_turn() -> void:
    for i in range(stack_durations.size()):
        stack_durations[i] -= 1
    stack_durations = stack_durations.filter(func(d: int)->bool: return d > 0)


# Check if effect has expired
func is_expired() -> bool:
    return stack_durations.size() == 0

# Get descriptive text for UI
func get_description() -> String:
    if stack_durations.size() > 1:
        return "%s (%d stacks, %d-%d turns)" % [get_effect_name(), stack_durations.size(), stack_durations.min(), stack_durations.max()]
    elif stack_durations.size() == 1:
        return "%s (%d turns)" % [get_effect_name(), stack_durations[0]]
    else:
        return "%s" % get_effect_name()

func get_base_description() -> String:
    return "%s for %d turns" % [get_effect_name(), duration]

func get_duration() -> int:
    return duration  # For compatibility, or pass duration as needed

func get_remaining_turns() -> int:
    if stack_durations.size() == 0:
        return 0
    return stack_durations.max()
