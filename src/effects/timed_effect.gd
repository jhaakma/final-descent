class_name TimedEffect extends StatusEffect

@export var duration: int = 1  # How many turns this effect lasts
var remaining_turns: int = 0

# Decrease remaining turns by 1
func tick_turn() -> void:
    remaining_turns -= 1

# Check if effect has expired
func is_expired() -> bool:
    return remaining_turns <= 0

# Get descriptive text for UI
func get_description() -> String:
    if remaining_turns > 0:
        return "%s (%d turns)" % [get_effect_name(), remaining_turns]
    else:
        return "%s" % get_effect_name()

func get_base_description() -> String:
    return "%s for %d turns" % [get_effect_name(), duration]

func get_duration() -> int:
    return duration

func get_remaining_turns() -> int:
    return remaining_turns

# Initialize the effect with its duration
func initialize() -> void:
    remaining_turns = duration

# Called when the effect is first applied to an entity
func on_applied(_target: CombatEntity) -> void:
    pass

# Called when the effect expires or is removed from an entity
func on_removed(_target: CombatEntity) -> void:
    pass
