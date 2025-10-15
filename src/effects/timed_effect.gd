class_name TimedEffect extends RemovableStatusEffect

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

# Override: Timed effects should be stored for tracking
func should_store_in_active_conditions() -> bool:
    return true

# Override: Handle refreshing duration when same timed effect is applied
func handle_existing_condition(_component: StatusEffectComponent, new_condition: StatusCondition, existing_condition: StatusCondition, target: CombatEntity) -> bool:
    var new_effect := new_condition.status_effect as TimedEffect
    var existing_effect := existing_condition.status_effect as TimedEffect

    # If the new effect has longer duration, refresh it
    if existing_effect.get_remaining_turns() < new_effect.get_duration():
        existing_effect.remaining_turns = new_effect.get_duration()
        LogManager.log_status_condition_applied(target, existing_condition, new_effect.get_duration())
        return true
    else:
        LogManager.log({
            text = "{You are} already affected by %s." % existing_condition.name,
            target = target,
            color = LogManager.LogColor.WARNING
        })
        return false

# Override: Handle applying new timed effect
func handle_new_condition(component: StatusEffectComponent, condition: StatusCondition, target: CombatEntity) -> bool:
    component.active_conditions[condition.name] = condition
    initialize()

    # Call lifecycle method
    on_applied(target)

    LogManager.log_status_condition_applied(target, condition, get_duration())
    component.effect_applied.emit(condition.name)
    return true

# Override: Provide duration for logging
func get_log_duration() -> int:
    return duration
