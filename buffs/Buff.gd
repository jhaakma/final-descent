class_name Buff extends Resource

@export var name: String = "Buff"
@export var description: String = "A beneficial effect."
@export var duration_turns: int = 5
@export var effect_color: EffectColor = EffectColor.POSITIVE

enum EffectColor {
    NEUTRAL,
    POSITIVE,
    NEGATIVE
}

static var EffectColorMap = {
    EffectColor.NEUTRAL: "grey", # Grey
    EffectColor.POSITIVE: "purple", # Purple
    EffectColor.NEGATIVE: "orange"  # Orange
}

# Current remaining duration (this gets decremented during play)
var remaining_duration: int

func _init():
	remaining_duration = duration_turns

# Abstract method - override in subclasses to define specific buff effects
func apply_effects() -> void:
	push_error("apply_effects() must be implemented in buff subclass")

# Abstract method - override in subclasses to remove specific buff effects
func remove_effects() -> void:
	push_error("remove_effects() must be implemented in buff subclass")

# Decrease duration by 1 turn (similar to status effects)
func tick_turn() -> void:
	remaining_duration -= 1

# Check if the buff has expired
func is_expired() -> bool:
	return remaining_duration <= 0

# Get descriptive text for UI
func get_description() -> String:
	return "%s (%d turns)" % [name, remaining_duration]