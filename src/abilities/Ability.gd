# DEPRECATED: This class is being phased out in favor of AbilityResource + AbilityInstance
# Keep for backward compatibility during transition
class_name Ability extends AbilityResource

# Legacy compatibility - redirect to new system
# These enums are kept for backward compatibility
enum AbilityState {
    READY,      # Ability is ready to be executed
    EXECUTING,  # Ability is in progress (multi-turn)
    COMPLETED   # Ability execution is finished
}

# Legacy state variables - deprecated but kept for compatibility
var current_state: AbilityState = AbilityState.READY
var caster_ref: CombatEntity = null
var target_ref: CombatEntity = null

# Override parent method with legacy support
func execute(_instance: AbilityInstance, _caster: CombatEntity, _target: CombatEntity) -> void:
    # For backward compatibility, call the old execute method if overridden
    execute_legacy(_caster, _target)

# Legacy execute method - override in subclasses for backward compatibility
func execute_legacy(_caster: CombatEntity, _target: CombatEntity) -> void:
    push_error("Ability.execute_legacy() must be overridden in subclasses. Consider migrating to AbilityResource.")

# Override parent method with legacy support
func continue_execution(_instance: AbilityInstance) -> void:
    # For backward compatibility, call the old continue_execution method if overridden
    continue_execution_legacy()

# Legacy continue_execution - override in subclasses for backward compatibility
func continue_execution_legacy() -> void:
    current_state = AbilityState.COMPLETED

# Legacy state methods
func is_executing() -> bool:
    return current_state == AbilityState.EXECUTING

func is_completed() -> bool:
    return current_state == AbilityState.COMPLETED

func reset_ability_state() -> void:
    current_state = AbilityState.READY
    caster_ref = null
    target_ref = null

func _start_execution(caster: CombatEntity, target: CombatEntity) -> void:
    current_state = AbilityState.EXECUTING
    caster_ref = caster
    target_ref = target

# Override parent methods with legacy support
func is_available(_instance: AbilityInstance, caster: CombatEntity) -> bool:
    return can_use(caster)

func get_status_text(_instance: AbilityInstance, _caster: CombatEntity) -> String:
    return ""

func on_select(_instance: AbilityInstance, _caster: CombatEntity) -> void:
    pass

func on_complete(_instance: AbilityInstance, _caster: CombatEntity) -> void:
    pass