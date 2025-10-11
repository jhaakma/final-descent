class_name StatusEffectComponent extends RefCounted

# Dictionary to store active status effects by name
var active_effects: Dictionary[String, StatusEffect] = {}
# The owning CombatEntity
var parent_entity: CombatEntity = null

# Signals for status effect events
signal effect_applied(effect_id: String)
signal effect_removed(effect_id: String)
signal effect_processed(effect_id: String, result: bool)


# Initialise with parent CombatEntity
func _init(parent: CombatEntity) -> void:
    parent_entity = parent

# Apply a status effect to the entity
func apply_effect(effect: StatusEffect, effect_target: CombatEntity) -> bool:
    if not effect:
        push_error("Attempted to apply null status effect")
        return false

    var effect_id := effect.get_effect_id()

    # Handle instant effects immediately (non-TimedEffect subclasses)
    if not effect is TimedEffect:
        # Apply the instant effect immediately
        if effect_target:
            var result := effect.apply_effect(effect_target)
            effect_processed.emit(effect_id, result)
            effect_applied.emit(effect_id)
            return result
        else:
            push_error("No target available for instant effect application")
            return false
        # Don't store instant effects in active_effects since they're one-time use

    # Handle timed effects (TimedEffect subclasses)
    var was_existing := active_effects.has(effect_id)

    # Check if we already have this effect
    var timed_effect := effect as TimedEffect

    if was_existing:
        var existing_effect := active_effects[effect_id] as TimedEffect
        if existing_effect.can_stack_with(effect):
            existing_effect.stack_with(effect)
            # No additional logging for stacking, the effect description will show stack count

        # If already at same duration, return false
        elif existing_effect.remaining_turns >= timed_effect.remaining_turns:
            LogManager.log_warning("%s is already affected by %s." % [effect_target.get_name(), existing_effect.get_effect_name()])
            return false
        else:
            # For timed effects that can't stack (at max stacks), refresh duration but keep max stacks
            if existing_effect.get_effect_id() == timed_effect.get_effect_id():
                existing_effect.remaining_turns = timed_effect.remaining_turns
                var duration := existing_effect.remaining_turns
                LogManager.log_status_effect_applied(effect_target, existing_effect, duration)
            else:
                # Replace with new effect for other cases
                active_effects[effect_id] = effect
                var duration := timed_effect.remaining_turns if effect is TimedEffect else 0
                LogManager.log_status_effect_applied(effect_target, effect, duration)
    else:
        # Add new effect
        active_effects[effect_id] = effect
        var duration := timed_effect.remaining_turns if effect is TimedEffect else 0
        LogManager.log_status_effect_applied(effect_target, effect, duration)

    effect_applied.emit(effect_id)
    return true

# Remove a specific status effect
func remove_effect(effect: StatusEffect) -> void:
    var effect_id := effect.get_effect_id()
    if active_effects.has(effect_id):
        if parent_entity:
            LogManager.log_status_effect_removed(parent_entity, effect.get_effect_name(), "was removed")
        active_effects.erase(effect_id)
        effect_removed.emit(effect_id)

# Check if entity has a specific status effect
func has_effect(effect_id: String) -> bool:
    if not active_effects.has(effect_id):
        return false
    var effect := active_effects[effect_id]
    # Only timed effects can expire, instant effects are removed immediately after application
    if effect is TimedEffect:
        return not (effect as TimedEffect).is_expired()
    return true

# Get a specific status effect
func get_effect(effect_id: String) -> StatusEffect:
    if has_effect(effect_id):
        return active_effects[effect_id]
    return null

# Process all status effects for one turn
func process_turn(target: CombatEntity) -> void:
    var effects_to_remove: Array[StatusEffect] = []
    for effect_id: String in active_effects.keys():
        var effect := active_effects[effect_id]
        # Apply the effect
        var result := effect.apply_effect(target)

        # Tick the effect's turn counter if it's a timed effect
        if effect is TimedEffect:
            (effect as TimedEffect).tick_turn()
        # Mark expired effects for removal (only timed effects can expire)
        if effect is TimedEffect and (effect as TimedEffect).is_expired():
            effects_to_remove.append(effect)

        effect_processed.emit(effect_id, result)

    # Remove expired effects
    for effect in effects_to_remove:
        var effect_id := effect.get_effect_id()
        if active_effects.has(effect_id):
            LogManager.log_status_effect_removed(target, effect.get_effect_name(), "expired")
            active_effects.erase(effect_id)
            effect_removed.emit(effect_id)


# Get all active status effects
func get_all_effects() -> Array[StatusEffect]:
    var effects: Array[StatusEffect] = []
    for effect: StatusEffect in active_effects.values():
        # Only include effects that haven't expired (for timed effects)
        if effect is TimedEffect:
            if not (effect as TimedEffect).is_expired():
                effects.append(effect)
        else:
            # Non-timed effects are always active if they're in the dictionary
            effects.append(effect)
    return effects

# Get descriptions of all active effects for UI
func get_effects_description() -> String:
    var descriptions: Array[String] = []

    for effect in get_all_effects():
        descriptions.append(effect.get_description())

    return ", ".join(descriptions)

# Clear all status effects
func clear_all_effects() -> void:
    for effect_id: String in active_effects.keys():
        effect_removed.emit(effect_id)
    active_effects.clear()

# Get total count of active effects
func get_effect_count() -> int:
    return get_all_effects().size()

# Check if entity has any status effects
func has_any_effects() -> bool:
    return get_effect_count() > 0
