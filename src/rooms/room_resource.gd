class_name RoomResource extends Resource

@export var title: String = "Room"
@export var description: String = "Description"
@export var weight: int = 10  # Used for weighted random selection
@export var min_floor: int = 0  # Minimum floor where this room can appear
@export var max_floor: int = -1  # Maximum floor where this room can appear

class RoomAction:
    var button_text: String
    var tooltip_text: String
    var is_enabled: bool = true  # Whether the action button is enabled
    var perform_action: Callable  # Function to perform the action

    func _init(_button_text: String, _tooltip_text:= "", _is_enabled:= true, _perform_action:= func()->void: pass) -> void:
        button_text = _button_text
        tooltip_text = _tooltip_text
        is_enabled = _is_enabled
        perform_action = _perform_action

    func get_button_text() -> String:
        return button_text

    func get_tooltip_text() -> String:
        return tooltip_text

    func is_action_enabled() -> bool:
        return is_enabled


# Can be overridden by subclasses
# Called when room actions are built
func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    pass

# Virtual method to be overridden by subclasses
# Called when room is entered/generated
func on_room_entered(_room_screen: RoomScreen) -> void:
    pass

func is_cleared_by_default() -> bool:
    return true

# Helper method for subclasses to add action buttons
func add_action_button(actions_grid: GridContainer, room_screen: RoomScreen, room_action: RoomAction) -> Button:
    print("Adding action button: %s" % room_action.get_button_text())
    var button := Button.new()
    button.text = room_action.get_button_text()
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    # Set tooltip if provided
    if room_action.get_tooltip_text() != "":
        button.tooltip_text = room_action.get_tooltip_text()

    actions_grid.add_child(button)
    button.pressed.connect(room_action.perform_action.bind(room_screen))
    return button

func _on_mark_cleared(room_screen: RoomScreen) -> void:
    room_screen.mark_cleared()

func valid_for_floor(_floor: int) -> bool:
    if _floor < min_floor:
        return false
    if max_floor >= 0 and _floor > max_floor:
        return false
    return true
