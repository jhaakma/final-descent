class_name RestRoomResource extends RoomResource

@export var heal_amount: int = 4
@export var rest_message: String = "You rest and recover."

func is_cleared_by_default() -> bool:
    return true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:

    var rest := RoomAction.new("Rest (+%d HP)" % heal_amount, "Take a moment to rest and recover health")
    rest.is_enabled = true
    rest.perform_action = _on_rest
    add_action_button(_actions_grid, _room_screen, rest)

func _on_rest(room_screen: RoomScreen) -> void:
    GameState.player.heal(heal_amount)
    LogManager.log_healing(rest_message)
    room_screen.mark_cleared()

