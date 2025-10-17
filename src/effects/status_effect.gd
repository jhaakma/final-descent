

class_name StatusEffect extends Resource

enum EffectType {
    NEUTRAL,
    POSITIVE,
    NEGATIVE
}

static var EffectTypeMap := {
    EffectType.NEUTRAL: "white", # White
    EffectType.POSITIVE: "green", # Green
    EffectType.NEGATIVE: "red"  # Red
}

# Context for logging and effect application
var application_context: StatusCondition = null

func get_effect_id() -> String:
    return get_class()

func get_effect_name() -> String:
    print_debug("get_effect_name() not implemented in subclass")
    return "Effect Name"

func create() -> StatusEffect:
    var effect_copy: StatusEffect = duplicate()
    return effect_copy

func get_effect_type() -> EffectType:
    return EffectType.NEUTRAL

func can_apply(_target: CombatEntity) -> bool:
    return true

# Returns true if status effect was applied successfully
func apply_effect(_target: CombatEntity) -> bool:
    # Return a StatusEffectResult with effect results
    return true

func get_effect_color() -> String:
    return EffectTypeMap.get(get_effect_type(), "white")

func get_description() -> String:
    print_debug("get_description() not implemented in subclass")
    return "Generic Status Effect"

func get_base_description() -> String:
    return get_description()

# Template method for handling effect application to status component
# Subclasses should override the specific methods they need to customize
func handle_application(component: StatusEffectComponent, condition: StatusCondition, target: CombatEntity) -> bool:
    var condition_id := condition.name

    # Check if effect should be stored in active conditions
    if not should_store_in_active_conditions():
        # Handle instant effects immediately
        if target:
            # Set application context for logging
            application_context = condition
            var result := apply_effect(target)
            application_context = null  # Clear context after use
            component.effect_processed.emit(condition_id, result)
            component.effect_applied.emit(condition_id)
            return result
        else:
            push_error("No target available for instant effect application")
            return false

    # Check for existing condition
    var existing_condition: StatusCondition = component.active_conditions.get(condition_id)
    if existing_condition:
        return handle_existing_condition(component, condition, existing_condition, target)
    else:
        return handle_new_condition(component, condition, target)

# Override in subclasses - determines if effect should be stored for tracking
func should_store_in_active_conditions() -> bool:
    return false  # Default: instant effects

# Override in subclasses - handles when the same condition already exists
func handle_existing_condition(_component: StatusEffectComponent, _new_condition: StatusCondition, existing_condition: StatusCondition, target: CombatEntity) -> bool:
    # Default: reject duplicate
    LogManager.log_event("{You are} already affected by %s." % existing_condition.name, {"target": target})
    return false

# Override in subclasses - handles applying a new condition
func handle_new_condition(component: StatusEffectComponent, condition: StatusCondition, target: CombatEntity) -> bool:
    # Default implementation for persistent effects
    component.active_conditions[condition.name] = condition

    # Call lifecycle method if available
    if self is RemovableStatusEffect:
        (self as RemovableStatusEffect).on_applied(target)

    # Apply the effect
    apply_effect(target)
    var duration := get_log_duration()
    if duration > 0:
        LogManager.log_event("{You are} {effect_verb} with {effect:%s} (%d turns)!" % [condition.get_log_name(), duration], {"target": target, "status_effect": self})
    else:
        LogManager.log_event("{You are} {effect_verb} with {effect:%s}!" % [condition.get_log_name()], {"target": target, "status_effect": self})
    component.effect_applied.emit(condition.name)
    return true

# Override in subclasses - provides duration for logging (0 for permanent/instant)
func get_log_duration() -> int:
    return 0