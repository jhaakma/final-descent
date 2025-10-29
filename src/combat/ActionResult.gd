class_name ActionResult extends RefCounted
## Type-safe data class for combat action results
## Replaces untyped dictionaries for better type safety and maintainability

enum ActionType {
    ATTACK,
    DEFEND,
    FLEE,
    ABILITY,
    SKIP,
    ITEM_USE
}

var action_type: ActionType
var success: bool
var damage_dealt: int
var message: String
var should_end_turn: bool
var combat_fled: bool

func _init(
    p_action_type: ActionType = ActionType.ATTACK,
    p_success: bool = false,
    p_damage_dealt: int = 0,
    p_message: String = "",
    p_should_end_turn: bool = true,
    p_combat_fled: bool = false
) -> void:
    action_type = p_action_type
    success = p_success
    damage_dealt = p_damage_dealt
    message = p_message
    should_end_turn = p_should_end_turn
    combat_fled = p_combat_fled

func get_action_name() -> String:
    return ActionType.keys()[action_type]

## Factory methods for common action results
static func create_attack_result(damage: int) -> ActionResult:
    return ActionResult.new(ActionType.ATTACK, true, damage, "", true, false)

static func create_defend_result() -> ActionResult:
    return ActionResult.new(ActionType.DEFEND, true, 0, "", true, false)

static func create_flee_success() -> ActionResult:
    return ActionResult.new(ActionType.FLEE, true, 0, "", false, true)

static func create_flee_failure() -> ActionResult:
    return ActionResult.new(ActionType.FLEE, false, 0, "", true, false)

static func create_skip_turn() -> ActionResult:
    return ActionResult.new(ActionType.SKIP, true, 0, "", true, false)

static func create_item_use_result() -> ActionResult:
    return ActionResult.new(ActionType.ITEM_USE, true, 0, "", true, false)