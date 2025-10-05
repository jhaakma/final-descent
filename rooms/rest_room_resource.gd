class_name RestRoomResource extends RoomResource

@export var heal_amount: int = 4
@export var rest_message: String = "You rest and recover."

func _init():
    cleared_by_default = true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    add_action_button(_actions_grid, "Rest (+%d HP)" % heal_amount, _on_rest.bind(_room_screen))

func _on_rest(room_screen: RoomScreen) -> void:
    GameState.heal(heal_amount)
    LogManager.log_healing(rest_message)
    room_screen.mark_cleared()

