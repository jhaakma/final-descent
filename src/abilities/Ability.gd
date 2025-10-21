class_name Ability extends Resource

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

# State tracking for multi-turn abilities
enum AbilityState {
    READY,      # Ability is ready to be executed
    EXECUTING,  # Ability is in progress (multi-turn)
    COMPLETED   # Ability execution is finished
}

var current_state: AbilityState = AbilityState.READY
var caster_ref: CombatEntity = null  # Store reference to caster for multi-turn abilities
var target_ref: CombatEntity = null  # Store reference to target for multi-turn abilities

func get_cooldown() -> int:
    return 0  # Default no cooldown

# Abstract method - override in subclasses to define specific ability behavior
func execute(_caster: CombatEntity, _target: CombatEntity) -> void:
    push_error("Ability.execute() must be overridden in subclasses")

# Continue execution for multi-turn abilities - override in subclasses that need it
func continue_execution() -> void:
    # Default implementation just marks as completed
    current_state = AbilityState.COMPLETED

# Check if this ability is currently executing (multi-turn)
func is_executing() -> bool:
    return current_state == AbilityState.EXECUTING

# Check if this ability execution is completed
func is_completed() -> bool:
    return current_state == AbilityState.COMPLETED

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

# Check if this ability can be used by the caster in current conditions
func can_use(_caster: CombatEntity) -> bool:
    return true

# Get the type of this ability for AI decision making
func get_ability_type() -> AbilityType:
    return AbilityType.UNKNOWN

# Get any additional description text for this ability's current state
func get_status_text(_caster: CombatEntity) -> String:
    return ""

# Check if this ability has any cooldown or preparation requirements
func is_available(caster: CombatEntity) -> bool:
    return can_use(caster)

# Called when this ability is selected but before execution (for preparation abilities)
func on_select(_caster: CombatEntity) -> void:
    pass

# Called after ability execution for cleanup
func on_complete(_caster: CombatEntity) -> void:
    pass