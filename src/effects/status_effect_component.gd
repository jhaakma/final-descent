
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

    # Use polymorphic application handling
    return effect.handle_application(self, condition, effect_target)

# Remove a specific status effect
func remove_effect(effect: StatusEffect) -> void:
    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        if condition.status_effect.get_effect_id() == effect.get_effect_id():
            # Call lifecycle method before removal
            var status_effect := condition.status_effect
            if status_effect is RemovableStatusEffect:
                (status_effect as RemovableStatusEffect).on_removed(parent_entity)

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

# Get a specific status condition by effect ID
func get_effect(status_effect_id: String) -> StatusCondition:
    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        if condition.status_effect.get_effect_id() == status_effect_id:
            var effect := condition.status_effect
            if effect is TimedEffect:
                if not (effect as TimedEffect).is_expired():
                    return condition
            else:
                return condition
    return null

# Check if entity has a specific condition by name
func has_condition(condition_name: String) -> bool:
    return active_conditions.has(condition_name)

# Remove a specific condition by name
func remove_condition(condition_name: String) -> bool:
    if not active_conditions.has(condition_name):
        return false

    var condition := active_conditions[condition_name]
    var status_effect := condition.status_effect

    # Call lifecycle method before removal
    if status_effect is RemovableStatusEffect:
        (status_effect as RemovableStatusEffect).on_removed(parent_entity)

    if parent_entity:
        LogManager.log_status_effect_removed(parent_entity, condition.get_log_name(), "was cured")

    active_conditions.erase(condition_name)
    effect_removed.emit(condition_name)
    return true

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
        # Constant effects don't tick or expire, they just persist

        effect_processed.emit(condition_id, result)

    # Remove expired conditions
    for condition in conditions_to_remove:
        var condition_id := condition.name
        if active_conditions.has(condition_id):
            # Call lifecycle method before removal
            var status_effect := condition.status_effect
            if status_effect is RemovableStatusEffect:
                (status_effect as RemovableStatusEffect).on_removed(target)

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
        var condition := active_conditions[condition_id]
        # Call lifecycle method before removal
        var status_effect := condition.status_effect
        if status_effect is RemovableStatusEffect:
            (status_effect as RemovableStatusEffect).on_removed(parent_entity)

        effect_removed.emit(condition_id)
    active_conditions.clear()

# Get total count of active conditions
func get_effect_count() -> int:
    return get_all_conditions().size()

# Check if entity has any status conditions
func has_any_effects() -> bool:
    return get_effect_count() > 0

# Remove all negative status effects and return them
func clear_all_negative_status_effects() -> Array[StatusCondition]:
    var removed_effects: Array[StatusCondition] = []
    for condition in get_all_conditions():
        if condition.status_effect.get_effect_type() == StatusEffect.EffectType.NEGATIVE:
            remove_effect(condition.status_effect)
            removed_effects.append(condition)
    return removed_effects
