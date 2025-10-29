class_name AbilityInstance extends RefCounted

# State tracking for multi-turn abilities
enum AbilityState {
    READY,      # Ability is ready to be executed
    EXECUTING,  # Ability is in progress (multi-turn)
    COMPLETED   # Ability execution is finished
}

var ability_resource: AbilityResource = null  # Reference to the configuration resource
var current_state: AbilityState = AbilityState.READY
var caster_ref: CombatEntity = null  # Store reference to caster for multi-turn abilities
var target_ref: CombatEntity = null  # Store reference to target for multi-turn abilities
var cooldown_remaining: int = 0  # Turns remaining until ability can be used again

func _init(resource: AbilityResource) -> void:
    ability_resource = resource

# Execute the ability using the resource configuration
func execute(caster: CombatEntity, target: CombatEntity = null) -> void:
    if ability_resource == null:
        push_error("AbilityInstance: No ability resource set")
        return

    if not is_available(caster):
        push_error("AbilityInstance: Ability '%s' is not available" % ability_resource.ability_name)
        return

    # Start execution and set references
    _start_execution(caster, target)

    # Delegate to the resource for actual ability behavior
    ability_resource.execute(self, caster, target)

    # Set cooldown after use
    cooldown_remaining = ability_resource.get_cooldown()

# Continue execution for multi-turn abilities
func continue_execution() -> void:
    if ability_resource == null:
        push_error("AbilityInstance: No ability resource set")
        return

    ability_resource.continue_execution(self)

# Check if this ability is currently executing (multi-turn)
func is_executing() -> bool:
    return current_state == AbilityState.EXECUTING

# Check if this ability execution is completed
func is_completed() -> bool:
    return current_state == AbilityState.COMPLETED

# Check if this ability is ready to use (not on cooldown, not executing)
func is_ready() -> bool:
    return current_state == AbilityState.READY and cooldown_remaining <= 0

# Check if this ability is available to use
func is_available(caster: CombatEntity) -> bool:
    if ability_resource == null:
        return false
    return ability_resource.is_available(self, caster)

# Reset ability state to ready
func reset_ability_state() -> void:
    current_state = AbilityState.READY
    caster_ref = null
    target_ref = null

# Start execution - called by execute()
func _start_execution(caster: CombatEntity, target: CombatEntity) -> void:
    current_state = AbilityState.EXECUTING
    caster_ref = caster
    target_ref = target

# Reduce cooldown by one turn
func reduce_cooldown() -> void:
    if cooldown_remaining > 0:
        cooldown_remaining -= 1

# Get the ability name from the resource
func get_ability_name() -> String:
    if ability_resource != null:
        return ability_resource.ability_name
    return "Unknown Ability"

# Get the ability type from the resource
func get_ability_type() -> AbilityResource.AbilityType:
    if ability_resource != null:
        return ability_resource.get_ability_type()
    return AbilityResource.AbilityType.UNKNOWN

# Get status text from the resource
func get_status_text(caster: CombatEntity) -> String:
    if ability_resource != null:
        return ability_resource.get_status_text(self, caster)
    return ""

# Get priority from the resource
func get_priority() -> int:
    if ability_resource != null:
        return ability_resource.priority
    return 0

# Check if this ability can be used by the caster
func can_use(caster: CombatEntity) -> bool:
    if ability_resource != null:
        return ability_resource.can_use(caster)
    return false

# Called when this ability is selected
func on_select(caster: CombatEntity) -> void:
    if ability_resource != null:
        ability_resource.on_select(self, caster)

# Called after ability execution for cleanup
func on_complete(caster: CombatEntity) -> void:
    if ability_resource != null:
        ability_resource.on_complete(self, caster)