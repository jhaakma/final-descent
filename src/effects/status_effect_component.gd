
class_name StatusEffectComponent extends RefCounted

# Dictionary to store active status conditions by name
var active_conditions: Dictionary[String, StatusCondition] = {}
# The owning CombatEntity
var parent_entity: CombatEntity = null

# Signals for status effect events
signal effect_applied(condition_id: String)
signal effect_removed(condition_id: String)
signal effect_processed(condition_id: String, result: bool)

# Initialise with parent CombatEntity
func _init(parent: CombatEntity) -> void:
    parent_entity = parent


# Apply a StatusEffect by converting it to a generic StatusCondition, then applying the condition
func apply_status_effect(effect: StatusEffect, effect_target: CombatEntity) -> bool:
    if not effect:
        push_error("Attempted to apply null status effect")
        return false
    var condition := StatusCondition.from_status_effect(effect)
    return apply_status_condition(condition, effect_target)

# Apply a StatusCondition resource to the entity
func apply_status_condition(_condition: StatusCondition, effect_target: CombatEntity) -> bool:
    if not _condition or not _condition.status_effect:
        push_error("Attempted to apply null status condition or effect")
        return false
    var condition := _condition.make_unique()
    var effect := condition.status_effect
    var condition_id := condition.name

    # Handle instant effects immediately (non-TimedEffect subclasses)
    if not effect is TimedEffect:
        if effect_target:
            var result := effect.apply_effect(effect_target)
            effect_processed.emit(condition_id, result)
            effect_applied.emit(condition_id)
            return result
        else:
            push_error("No target available for instant effect application")
            return false
        # Don't store instant effects in active_conditions since they're one-time use


    # Handle timed effects (TimedEffect subclasses)
    var conditon_already_applied := active_conditions.has(condition_id)
    var timed_effect := effect as TimedEffect

    if conditon_already_applied:
        var existing_condition := active_conditions[condition_id]
        var existing_effect := existing_condition.status_effect as TimedEffect
        if existing_effect.can_stack_with(effect):
            # Add a new stack with its own duration
            existing_effect.stack_with(effect)
            LogManager.log({
                text = "{You are} affected by %s. Stack added (%d stacks, %d-%d turns)." % [existing_condition.name, existing_effect.stack_durations.size(), existing_effect.stack_durations.min(), existing_effect.stack_durations.max()],
                target = effect_target,
                color = LogManager.LogColor.COMBAT
            })
        elif existing_effect.stack_durations.max() >= timed_effect.get_duration(): #number of turns remainin is equal/greater than new duration
            LogManager.log({
                text = "{You are} already affected by %s." % existing_condition.name,
                target = effect_target,
                color = LogManager.LogColor.WARNING
            })
            return false
        else:
            # At max stacks, refresh the shortest stack duration
            var min_index := 0
            var min_duration := existing_effect.stack_durations[0]
            for i in range(existing_effect.stack_durations.size()):
                if existing_effect.stack_durations[i] < min_duration:
                    min_duration = existing_effect.stack_durations[i]
                    min_index = i
            existing_effect.stack_durations[min_index] = timed_effect.get_duration()
        LogManager.log_status_condition_applied(effect_target, existing_condition, existing_effect.stack_durations.max())
    else:
        # Add new condition with initial stack
        active_conditions[condition_id] = condition
        if effect is TimedEffect:
            timed_effect.stack_durations = [timed_effect.get_duration()]
            LogManager.log_status_condition_applied(effect_target, condition, timed_effect.get_duration())
        else:
            LogManager.log_status_condition_applied(effect_target, condition, 0)

    effect_applied.emit(condition_id)
    return true

# Remove a specific status effect
func remove_effect(effect: StatusEffect) -> void:
    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        if condition.status_effect.get_effect_id() == effect.get_effect_id():
            if parent_entity:
                LogManager.log_status_effect_removed(parent_entity, condition.get_log_name(), "was removed")
            active_conditions.erase(condition_id)
            effect_removed.emit(condition_id)
            return

# Check if entity has a specific status effect
func has_effect(status_effect_id: String) -> bool:
    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        if condition.status_effect.get_effect_id() == status_effect_id:
            var effect := condition.status_effect
            if effect is TimedEffect:
                return not (effect as TimedEffect).is_expired()
            return true
    return false

# Get a specific status condition
func get_effect(condition_id: String) -> StatusCondition:
    if has_effect(condition_id):
        return active_conditions[condition_id]
    return null

# Process all status conditions for one turn
func process_turn(target: CombatEntity) -> void:
    var conditions_to_remove: Array[StatusCondition] = []
    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        var effect := condition.status_effect
        var result := effect.apply_effect(target)

        if effect is TimedEffect:
            var timed_effect := effect as TimedEffect
            timed_effect.tick_turn()
            if timed_effect.is_expired():
                conditions_to_remove.append(condition)
        effect_processed.emit(condition_id, result)

    # Remove expired conditions
    for condition in conditions_to_remove:
        var condition_id := condition.name
        if active_conditions.has(condition_id):
            LogManager.log_status_effect_removed(target, condition.get_log_name(), "expired")
            active_conditions.erase(condition_id)
            effect_removed.emit(condition_id)

# Get all active status conditions
func get_all_conditions() -> Array[StatusCondition]:
    var conditions: Array[StatusCondition] = []
    for condition: StatusCondition in active_conditions.values():
        var effect := condition.status_effect
        if effect is TimedEffect:
            if not (effect as TimedEffect).is_expired():
                conditions.append(condition)
        else:
            conditions.append(condition)
    return conditions

# Get descriptions of all active conditions for UI
func get_effects_description() -> String:
    var descriptions: Array[String] = []
    for condition in get_all_conditions():
        descriptions.append(condition.status_effect.get_description())
    return ", ".join(descriptions)

# Clear all status conditions
func clear_all_effects() -> void:
    for condition_id: String in active_conditions.keys():
        effect_removed.emit(condition_id)
    active_conditions.clear()

# Get total count of active conditions
func get_effect_count() -> int:
    return get_all_conditions().size()

# Check if entity has any status conditions
func has_any_effects() -> bool:
    return get_effect_count() > 0
