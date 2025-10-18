class_name ConstantEffect extends RemovableStatusEffect

# Constant effects are permanent status effects that don't expire naturally
# They are typically used for:
# - Permanent stat buffs/debuffs
# - Resistance effects
# - Equipment-based constant effects that last while equipped
# - Player progression unlocks

# Flag to track if this is a removable constant effect
@export var is_removable: bool = true

# Check if this effect is permanent (cannot be removed by normal means)
func is_permanent() -> bool:
    return not is_removable

# Constant effects don't tick or expire on their own
func is_expired() -> bool:
    return false

# Get descriptive text for UI (no turn counter)
# Subclasses should override this to provide magnitude and unit
func get_description() -> String:
    print_debug("get_description() not implemented in ConstantEffect subclass: %s" % get_class())
    return get_effect_name()

func get_base_description() -> String:
    if is_permanent():
        return "%s (permanent)" % get_effect_name()
    else:
        return "%s (constant)" % get_effect_name()

# Called when the effect is first applied to an entity
func on_applied(_target: CombatEntity) -> void:
    pass

# Called when the effect is removed from an entity
func on_removed(_target: CombatEntity) -> void:
    pass

# Override apply_effect - constant effects typically modify stats or state
# rather than doing something each turn like timed effects
func apply_effect(_target: CombatEntity) -> bool:
    # Most constant effects don't need to "do" anything each turn
    # They are passive modifications to stats, resistances, etc.
    # Subclasses can override this if they need active behavior
    return true

# Override: Constant effects should be stored for tracking
func should_store_in_active_conditions() -> bool:
    return true

# Override: Constant effects don't stack by default, except for equipment effects
func handle_existing_condition(_component: StatusEffectComponent, new_condition: StatusCondition, existing_condition: StatusCondition, target: CombatEntity) -> bool:
    # Allow stacking for equipment-based effects by incrementing stack count
    if new_condition.source_type == StatusCondition.SourceType.EQUIPMENT:
        existing_condition.add_equipment_stack()
        # Don't show a duplicate message - effect is already active
        return true

    # For consumables and other sources, show "already affected" message
    LogManager.log_event("{You are} already affected by %s." % existing_condition.name, {"target": target})
    return false

# Override: Handle applying new constant effect
func handle_new_condition(component: StatusEffectComponent, condition: StatusCondition, target: CombatEntity) -> bool:
    component.active_conditions[condition.name] = condition

    # Call lifecycle method if available
    if self is RemovableStatusEffect:
        (self as RemovableStatusEffect).on_applied(target)

    # Apply the constant effect once
    apply_effect(target)
    LogManager.log_event("{You are} {effect_verb} with {effect:%s}!" % [condition.get_log_name()], {"target": target, "status_effect": self})
    component.effect_applied.emit(condition.name)
    return true