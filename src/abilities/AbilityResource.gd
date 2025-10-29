class_name AbilityResource extends Resource

@export var ability_name: String = "Ability"
@export var description: String = "A basic ability."
@export var priority: int = 0  # Higher priority abilities are preferred in AI selection

# Types of abilities for categorization and AI decision making
enum AbilityType {
    UNKNOWN,     # Default/fallback type
    ATTACK,      # Offensive abilities that deal damage
    DEFEND,      # Defensive abilities that reduce incoming damage
    SUPPORT,    # Support abilities that provide buffs or healing
    FLEE         # Escape abilities that attempt to end combat
}

func get_cooldown() -> int:
    return 0  # Default no cooldown

# Abstract method - override in subclasses to define specific ability behavior
# Takes an AbilityInstance for access to state data like current_state, caster_ref, target_ref
func execute(_instance: AbilityInstance, _caster: CombatEntity, _target: CombatEntity) -> void:
    push_error("AbilityResource.execute() must be overridden in subclasses")

# Continue execution for multi-turn abilities - override in subclasses that need it
func continue_execution(_instance: AbilityInstance) -> void:
    # Default implementation just marks as completed
    _instance.current_state = AbilityInstance.AbilityState.COMPLETED

# Check if this ability can be used by the caster in current conditions
func can_use(_caster: CombatEntity) -> bool:
    return true

# Get the type of this ability for AI decision making
func get_ability_type() -> AbilityType:
    return AbilityType.UNKNOWN

# Get any additional description text for this ability's current state
func get_status_text(_instance: AbilityInstance, _caster: CombatEntity) -> String:
    return ""

# Check if this ability has any cooldown or preparation requirements
func is_available(_instance: AbilityInstance, _caster: CombatEntity) -> bool:
    return can_use(_caster) and _instance.is_ready()

# Called when this ability is selected but before execution (for preparation abilities)
func on_select(_instance: AbilityInstance, _caster: CombatEntity) -> void:
    pass

# Called after ability execution for cleanup
func on_complete(_instance: AbilityInstance, _caster: CombatEntity) -> void:
    pass