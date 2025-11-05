class_name TimedEffect extends RemovableStatusEffect

# Immutable effect configuration - these define the effect template
@export var expire_after_turns: int = 1  # Base duration (never changes - immutable)

# Get descriptive text for UI (base description with default duration)
# Subclasses should override this to provide magnitude, unit and turns
func get_description() -> String:
    print_debug("get_description() not implemented in TimedEffect subclass: %s" % get_class())
    return "%s (%d turns)" % [get_effect_name(), expire_after_turns]

func get_base_description() -> String:
    return "%s for %d turns" % [get_effect_name(), expire_after_turns]

# Get description with runtime instance data (remaining turns)
# Subclasses should override this for custom descriptions
func get_description_with_instance(instance: EffectInstance) -> String:
    if instance:
        return "%s (%d turns)" % [get_effect_name(), instance.get_remaining_turns()]
    return get_description()

func get_duration() -> int:
    return expire_after_turns


# For TimedEffect, magnitude represents the duration/turns
func get_magnitude() -> int:
    return expire_after_turns

# Timing system methods - getters for immutable configuration
func get_expire_timing() -> EffectTiming.Type:
    return EffectTiming.Type.TURN_START


func get_expire_after_turns() -> int:
    return expire_after_turns

func set_expire_after_turns(turns: int) -> void:
    expire_after_turns = turns


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

    # Compare durations from the immutable effects
    var new_duration := new_effect.get_expire_after_turns()
    var existing_instance := existing_condition.effect_instance

    if not existing_instance:
        push_error("Existing condition missing effect instance")
        return false

    # If the new effect has longer duration, refresh the instance
    if existing_instance.get_remaining_turns() < new_duration:
        existing_instance.set_duration(new_duration)
        LogManager.log_event("{You are} {effect_verb} with {effect:%s} (%d turns)!" % [existing_condition.get_log_name(), new_duration], {"target": target, "status_effect": existing_condition.status_effect})
        return true
    else:
        LogManager.log_event("{You are} already affected by %s." % existing_condition.name, {"target": target})
        return false

# Override: Handle applying new timed effect
func handle_new_condition(component: StatusEffectComponent, condition: StatusCondition, target: CombatEntity) -> bool:
    # Ensure the condition has an effect instance
    if not condition.effect_instance:
        condition.effect_instance = EffectInstance.new(condition.status_effect)

    component.active_conditions[condition.name] = condition

    # Call lifecycle method
    on_applied(target)

    LogManager.log_event("{You are} {effect_verb} with {effect:%s} (%d turns)!" % [condition.get_log_name(), get_duration()], {"target": target, "status_effect": condition.status_effect})
    component.effect_applied.emit(condition.name)
    return true

# Override: Provide duration for logging
func get_log_duration() -> int:
    return expire_after_turns
