class_name TimedEffect extends RemovableStatusEffect

# New timing system properties - marked as @export to preserve during duplication
@export var expire_timing: EffectTiming.Type = EffectTiming.Type.ROUND_END  # When during combat this effect should expire
@export var expire_after_turns: int = 1  # Original duration (never changes)
@export var expire_condition: Callable  # Optional custom expiration condition
@export var applied_turn: int = 0  # (Legacy, not used with new duration logic)

# Instance variable for tracking remaining duration (not exported, so not saved in resources)
var remaining_duration: int = -1  # -1 means not initialized yet

# Get descriptive text for UI
# Subclasses should override this to provide magnitude, unit and turns
func get_description() -> String:
    print_debug("get_description() not implemented in TimedEffect subclass: %s" % get_class())
    return "%s (%d turns)" % [get_effect_name(), expire_after_turns]

func get_base_description() -> String:
    return "%s for %d turns" % [get_effect_name(), expire_after_turns]

func get_duration() -> int:
    return expire_after_turns

func get_remaining_turns() -> int:
    # If not initialized yet, return the original duration
    if remaining_duration == -1:
        return expire_after_turns
    return remaining_duration

# For TimedEffect, magnitude represents the duration/turns
func get_magnitude() -> int:
    return expire_after_turns

# Initialize the effect with its duration
func initialize() -> void:
    # Initialize remaining duration if not already set
    if remaining_duration == -1:
        remaining_duration = expire_after_turns

# New timing system methods
func get_expire_timing() -> EffectTiming.Type:
    return expire_timing

func set_expire_timing(timing: EffectTiming.Type) -> void:
    expire_timing = timing

func get_expire_after_turns() -> int:
    return expire_after_turns

func set_expire_after_turns(turns: int) -> void:
    expire_after_turns = turns
    # Also reset remaining duration to the new value
    remaining_duration = turns

func get_expire_condition() -> Callable:
    return expire_condition

func set_expire_condition(condition: Callable) -> void:
    expire_condition = condition

# Check if this effect should expire at the given timing and turn
func should_expire_at(timing: EffectTiming.Type, _current_turn: int) -> bool:
    # Check timing first
    if expire_timing != timing:
        return false

    # If custom condition exists and is valid, use it (overrides turn count)
    if expire_condition.is_valid():
        return expire_condition.call()

    # Expire if remaining_duration is 0 or less
    return remaining_duration <= 0

# Decrement remaining turns - called when effect is processed
func process_turn() -> void:
    # Ensure we're initialized
    if remaining_duration == -1:
        remaining_duration = expire_after_turns

    if remaining_duration > 0:
        remaining_duration -= 1

# Called when the effect is first applied to an entity
func on_applied(_target: CombatEntity) -> void:
    pass

# Called when the effect expires or is removed from an entity
func on_removed(_target: CombatEntity) -> void:
    pass

# Override: Timed effects should be stored for tracking
func should_store_in_active_conditions() -> bool:
    return true

# Override: Handle refreshing duration when same timed effect is applied
func handle_existing_condition(_component: StatusEffectComponent, new_condition: StatusCondition, existing_condition: StatusCondition, target: CombatEntity) -> bool:
    var new_effect := new_condition.status_effect as TimedEffect
    var existing_effect := existing_condition.status_effect as TimedEffect

    # If the new effect has longer duration, refresh it
    if existing_effect.get_expire_after_turns() < new_effect.get_expire_after_turns():
        existing_effect.set_expire_after_turns(new_effect.get_expire_after_turns())
        LogManager.log_event("{You are} {effect_verb} with {effect:%s} (%d turns)!" % [existing_condition.get_log_name(), new_effect.get_expire_after_turns()], {"target": target, "status_effect": existing_condition.status_effect})
        return true
    else:
        LogManager.log_event("{You are} already affected by %s." % existing_condition.name, {"target": target})
        return false

# Override: Handle applying new timed effect
func handle_new_condition(component: StatusEffectComponent, condition: StatusCondition, target: CombatEntity) -> bool:
    component.active_conditions[condition.name] = condition
    initialize()

    # Call lifecycle method
    on_applied(target)

    LogManager.log_event("{You are} {effect_verb} with {effect:%s} (%d turns)!" % [condition.get_log_name(), get_duration()], {"target": target, "status_effect": condition.status_effect})
    component.effect_applied.emit(condition.name)
    return true

# Override: Provide duration for logging
func get_log_duration() -> int:
    return expire_after_turns
