class_name EffectInstance extends RefCounted

## Holds the mutable runtime state for an effect applied to an entity
## Separates instance data from immutable effect resources

# Reference to the immutable effect resource
var effect: StatusEffect

# Runtime state - mutable properties
var remaining_duration: int = -1  # For timed effects, tracks remaining turns
var applied_turn: int = 0  # Turn when effect was applied (for tracking)
var custom_data: Dictionary = {}  # For effect-specific data that needs tracking

func _init(_effect: StatusEffect) -> void:
    effect = _effect

    # Initialize duration for timed effects
    if effect is TimedEffect:
        var timed := effect as TimedEffect
        remaining_duration = timed.expire_after_turns

## Get the remaining duration for timed effects
func get_remaining_turns() -> int:
    if remaining_duration == -1:
        if effect is TimedEffect:
            return (effect as TimedEffect).expire_after_turns
        return 0
    return remaining_duration

## Decrement the remaining duration
func process_turn() -> void:
    if remaining_duration > 0:
        remaining_duration -= 1

## Check if this effect instance should expire at the given timing and turn
func should_expire_at(timing: EffectTiming.Type, current_turn: int) -> bool:
    if not effect is TimedEffect:
        return false

    var timed := effect as TimedEffect

    # Check timing first
    if timed.get_expire_timing() != timing:
        return false

    # Primary expiration check: use the provided current turn compared to configured duration
    if current_turn >= timed.expire_after_turns:
        return true

    # Fallback: if remaining_duration is being used by runtime processing
    if remaining_duration == -1:
        return false

    return remaining_duration <= 0

## Reset duration to original value (for refreshing effects)
func reset_duration() -> void:
    if effect is TimedEffect:
        remaining_duration = (effect as TimedEffect).expire_after_turns

## Update duration to a new value
func set_duration(turns: int) -> void:
    remaining_duration = turns
