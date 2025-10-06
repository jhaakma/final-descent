class_name StatusEffectComponent extends Node

# Dictionary to store active status effects by name
var active_effects: Dictionary = {}

# Signals for status effect events
signal effect_applied(effect_name: String)
signal effect_removed(effect_name: String)
signal effect_processed(effect_name: String, result: StatusEffectResult)

# Apply a status effect to the entity
func apply_effect(effect: StatusEffect, target = null) -> void:
    if not effect:
        push_error("Attempted to apply null status effect")
        return

    var effect_name = effect.effect_name
    var effect_target = target if target else get_parent()

    # Handle instant effects immediately (non-TimedEffect subclasses)
    if not effect is TimedEffect:
        # Apply the instant effect immediately
        if effect_target:
            var result = effect.apply_effect(effect_target)
            effect_processed.emit(effect_name, result)
            effect_applied.emit(effect_name)
        else:
            push_error("No target available for instant effect application")
        # Don't store instant effects in active_effects since they're one-time use
        return

    # Handle timed effects (TimedEffect subclasses)
    var was_existing = active_effects.has(effect_name)

    # Check if we already have this effect
    if was_existing:
        var existing_effect = active_effects[effect_name]
        if existing_effect.can_stack_with(effect):
            existing_effect.stack_with(effect)
            # No additional logging for stacking, the effect description will show stack count
        else:
            # Replace with new effect (refresh duration)
            active_effects[effect_name] = effect
            var duration = effect.remaining_turns if effect is TimedEffect else 0
            LogManager.log_status_effect_applied(effect_target, effect_name, duration)
    else:
        # Add new effect
        active_effects[effect_name] = effect
        var duration = effect.remaining_turns if effect is TimedEffect else 0
        LogManager.log_status_effect_applied(effect_target, effect_name, duration)

    effect_applied.emit(effect_name)

# Remove a specific status effect
func remove_effect(effect_name: String) -> void:
    if active_effects.has(effect_name):
        var target = get_parent()
        if target:
            LogManager.log_status_effect_removed(target, effect_name, "removed")
        active_effects.erase(effect_name)
        effect_removed.emit(effect_name)

# Check if entity has a specific status effect
func has_effect(effect_name: String) -> bool:
    if not active_effects.has(effect_name):
        return false
    var effect = active_effects[effect_name]
    # Only timed effects can expire, instant effects are removed immediately after application
    if effect is TimedEffect:
        return not effect.is_expired()
    return true

# Get a specific status effect
func get_effect(effect_name: String) -> StatusEffect:
    if has_effect(effect_name):
        return active_effects[effect_name]
    return null

# Process all status effects for one turn
func process_turn(target) -> Array[StatusEffectResult]:
    var results: Array[StatusEffectResult] = []
    var effects_to_remove: Array[String] = []

    for effect_name in active_effects.keys():
        var effect = active_effects[effect_name]

        # Apply the effect
        var result = effect.apply_effect(target)
        results.append(result)

        # Tick the effect's turn counter if it's a timed effect
        if effect is TimedEffect:
            effect.tick_turn()

        # Mark expired effects for removal (only timed effects can expire)
        if effect is TimedEffect and effect.is_expired():
            effects_to_remove.append(effect_name)

        effect_processed.emit(effect_name, result)

    # Remove expired effects
    for effect_name in effects_to_remove:
        if active_effects.has(effect_name):
            LogManager.log_status_effect_removed(target, effect_name, "expired")
            active_effects.erase(effect_name)
            effect_removed.emit(effect_name)

    return results

# Get all active status effects
func get_all_effects() -> Array[StatusEffect]:
    var effects: Array[StatusEffect] = []
    for effect in active_effects.values():
        # Only include effects that haven't expired (for timed effects)
        if effect is TimedEffect:
            if not effect.is_expired():
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
    for effect_name in active_effects.keys():
        effect_removed.emit(effect_name)
    active_effects.clear()

# Get total count of active effects
func get_effect_count() -> int:
    return get_all_effects().size()

# Check if entity has any status effects
func has_any_effects() -> bool:
    return get_effect_count() > 0
