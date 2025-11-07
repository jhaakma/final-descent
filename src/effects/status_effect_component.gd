
class_name StatusEffectComponent extends RefCounted

# Dictionary to store active status conditions by name
var active_conditions: Dictionary[String, StatusCondition] = {}
# The owning CombatEntity
var parent_entity: CombatEntity = null

# Internal signals for debugging and potential future use
# NOTE: These are not currently connected - for internal use only
signal effect_applied(condition_id: String)  # Emitted when effect is applied
signal effect_removed(condition_id: String)  # Emitted when effect is removed
signal effect_processed(condition_id: String, result: bool)  # Emitted when effect is processed

# Initialise with parent CombatEntity
func _init(parent: CombatEntity) -> void:
    parent_entity = parent


# Apply a StatusEffect by converting it to a generic StatusCondition, then applying the condition
func apply_status_effect(effect: StatusEffect, effect_target: CombatEntity, applied_turn: int = -1) -> bool:
    if not effect:
        push_error("Attempted to apply null status effect")
        return false
    var condition := StatusCondition.from_status_effect(effect)
    return apply_status_condition(condition, effect_target, applied_turn)

# Apply a StatusCondition resource to the entity
func apply_status_condition(_condition: StatusCondition, effect_target: CombatEntity, applied_turn: int = -1) -> bool:
    if not _condition or not _condition.status_effect:
        push_error("Attempted to apply null status condition or effect")
        return false
    var condition := _condition.make_unique()
    var effect := condition.status_effect

    # Set applied_turn on the instance if provided
    if applied_turn > 0 and condition.effect_instance:
        condition.effect_instance.applied_turn = applied_turn

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
                LogManager.log_event("{Your} {effect:%s} was removed." % condition.get_log_name(), {"target": parent_entity, "status_effect": status_effect})
            active_conditions.erase(condition_id)
            effect_removed.emit(condition_id)
            return

# Remove an equipment stack from an effect, removing the effect entirely if no stacks remain
func remove_equipment_stack(effect: StatusEffect) -> void:
    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        if condition.status_effect.get_effect_id() == effect.get_effect_id():
            # Remove one equipment stack
            var should_remove_entirely := condition.remove_equipment_stack()

            if should_remove_entirely:
                # No more stacks - remove the entire effect
                var status_effect := condition.status_effect
                if status_effect is RemovableStatusEffect:
                    (status_effect as RemovableStatusEffect).on_removed(parent_entity)

                if parent_entity:
                    LogManager.log_event("{Your} {effect:%s} faded." % condition.get_log_name(), {"target": parent_entity, "status_effect": status_effect})
                active_conditions.erase(condition_id)
                effect_removed.emit(condition_id)  # Emit signal for UI updates
            return# Check if entity has a specific status effect

func has_effect(status_effect_id: String) -> bool:
    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        if condition.status_effect.get_effect_id() == status_effect_id:
            return true
    return false

# Get a specific status condition by effect ID
func get_effect(status_effect_id: String) -> StatusCondition:
    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        if condition.status_effect.get_effect_id() == status_effect_id:
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
        LogManager.log_event("{Your} {effect:%s} was cured." % condition.get_log_name(), {"target": parent_entity, "status_effect": status_effect})

    active_conditions.erase(condition_name)
    effect_removed.emit(condition_name)
    return true

# Process status effects for a general turn (legacy compatibility)
func process_turn(target: CombatEntity) -> void:
    process_all_timed_effects(target)

# Process status effects that should expire at a specific timing phase
func process_status_effects_at_timing(timing: EffectTiming.Type, current_turn: int, target: CombatEntity) -> void:
    print("DEBUG: StatusEffectComponent processing timing ", timing, " on turn ", current_turn, " for ", target.get_name())
    if timing == EffectTiming.Type.ROUND_START:
        print("DEBUG: ROUND_START call - Stack trace:")
        print(get_stack())
    print("DEBUG: Active conditions: ", active_conditions.keys())

    var conditions_to_remove: Array[StatusCondition] = []

    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        var effect := condition.status_effect
        print("DEBUG: Processing condition '", condition_id, "' with effect: ", effect)

        # Apply timed effects at their designated timing
        if effect is TimedEffect:
            var timed_effect := effect as TimedEffect
            var instance := condition.effect_instance

            if not instance:
                push_error("TimedEffect condition missing effect instance: " + condition_id)
                continue

            print("DEBUG: TimedEffect - expire timing: ", timed_effect.get_expire_timing(), ", current timing: ", timing)

            # Apply the effect if this is the correct timing
            if timed_effect.get_expire_timing() == timing:
                print("DEBUG: Timing matches! Applying effect")
                timed_effect.apply_effect(target)
                # Decrement turns after applying the effect
                instance.process_turn()
                print("DEBUG: Remaining turns after processing: ", instance.get_remaining_turns())
                # Emit signal for UI updates when effect is processed (duration changed)
                effect_processed.emit(condition_id, true)
            else:
                print("DEBUG: Timing doesn't match, skipping apply_effect")

            # Check if this effect should expire at this timing and turn
            if instance.should_expire_at(timing):
                print("DEBUG: Effect should expire, adding to removal list")
                conditions_to_remove.append(condition)
            else:
                print("DEBUG: Effect should not expire yet")

    print("DEBUG: Conditions to remove: ", conditions_to_remove.size())

    # Remove expired conditions
    for condition in conditions_to_remove:
        var condition_id := condition.name
        if active_conditions.has(condition_id):
            # Call lifecycle method before removal
            var status_effect := condition.status_effect
            if status_effect is RemovableStatusEffect:
                (status_effect as RemovableStatusEffect).on_removed(target)

            LogManager.log_event("{Your} {effect:%s} expired." % condition.get_log_name(), {"target": target, "status_effect": status_effect})
            active_conditions.erase(condition_id)
            effect_removed.emit(condition_id)

# Process all timed effects regardless of timing (for room transitions)
func process_all_timed_effects(target: CombatEntity) -> void:
    print("DEBUG: Processing ALL timed effects for room transition on ", target.get_name())

    var conditions_to_remove: Array[StatusCondition] = []

    for condition_id: String in active_conditions.keys():
        var condition := active_conditions[condition_id]
        var effect := condition.status_effect

        # Process all timed effects
        if effect is TimedEffect:
            var timed_effect := effect as TimedEffect
            var instance := condition.effect_instance

            if not instance:
                push_error("TimedEffect condition missing effect instance: " + condition_id)
                continue

            print("DEBUG: Processing timed effect: ", condition_id, " (", instance.get_remaining_turns(), " turns remaining)")

            # Apply the effect
            timed_effect.apply_effect(target)
            # Decrement turns after applying the effect
            instance.process_turn()
            print("DEBUG: Remaining turns after processing: ", instance.get_remaining_turns())

            # Check if effect should now expire (0 or negative turns)
            if instance.get_remaining_turns() <= 0:
                print("DEBUG: Effect expired, adding to removal list")
                conditions_to_remove.append(condition)

    # Remove expired conditions
    for condition in conditions_to_remove:
        var condition_id := condition.name
        if active_conditions.has(condition_id):
            # Call lifecycle method before removal
            var status_effect := condition.status_effect
            if status_effect is RemovableStatusEffect:
                (status_effect as RemovableStatusEffect).on_removed(target)

            LogManager.log_event("{Your} {effect:%s} expired." % condition.get_log_name(), {"target": target, "status_effect": status_effect})
            print("DEBUG: Removing expired condition: ", condition_id)
            active_conditions.erase(condition_id)
            effect_removed.emit(condition_id)

# Get all active status conditions
func get_all_conditions() -> Array[StatusCondition]:
    var conditions: Array[StatusCondition] = []
    for condition: StatusCondition in active_conditions.values():
        conditions.append(condition)
    return conditions

# Get descriptions of all active conditions for UI
func get_effects_description() -> String:
    var descriptions: Array[String] = []
    for condition in get_all_conditions():
        descriptions.append(condition.get_description())
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
