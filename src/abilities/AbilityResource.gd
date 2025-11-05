class_name AbilityResource extends Resource

@export var ability_name: String = "Ability"
@export var description: String = "A basic ability."
@export var priority: int = 0  # Higher priority abilities are preferred in AI selection
@export var log_action_player: String = ""  # Optional override for player action verb (e.g., "attack" instead of "use [ability_name]")
@export var log_action_enemy: String = ""   # Optional override for enemy action verb (e.g., "attacks" or "breathes fire")

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

# Helper method to get the action verb for logging
# Returns [player_form, non_player_form] for use with {action} pattern in LogManager
#
# Default behavior (when log_action_player/enemy are empty):
#   - "You use [ability_name] for X damage"
#   - "[Enemy] uses [ability_name] for X damage"
#
# With action overrides set (e.g., log_action_player="attack", log_action_enemy="attacks"):
#   - "You attack for X damage"
#   - "[Enemy] attacks for X damage"
#
# For complex actions (e.g., log_action_player="breathe fire", log_action_enemy="breathes fire"):
#   - "You breathe fire for X damage"
#   - "[Enemy] breathes fire for X damage"
func get_log_action_verb() -> Array:
    if log_action_player != "" and log_action_enemy != "":
        # Use explicit overrides
        return [log_action_player, log_action_enemy]
    else:
        # Default to "use [ability_name]" / "uses [ability_name]"
        return ["use %s" % ability_name, "uses %s" % ability_name]