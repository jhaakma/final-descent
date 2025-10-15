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
func get_description() -> String:
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

# Override: Constant effects don't stack by default
func handle_existing_condition(_component: StatusEffectComponent, _new_condition: StatusCondition, existing_condition: StatusCondition, target: CombatEntity) -> bool:
    LogManager.log({
        text = "{You are} already affected by %s." % existing_condition.name,
        target = target,
        color = LogManager.LogColor.WARNING
    })
    return false

# Override: Handle applying new constant effect
func handle_new_condition(component: StatusEffectComponent, condition: StatusCondition, target: CombatEntity) -> bool:
    component.active_conditions[condition.name] = condition

    # Call lifecycle method if available
    if self is RemovableStatusEffect:
        (self as RemovableStatusEffect).on_applied(target)

    # Apply the constant effect once
    apply_effect(target)
    LogManager.log_status_condition_applied(target, condition, 0) # 0 duration for constant
    component.effect_applied.emit(condition.name)
    return true