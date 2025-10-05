class_name RoomResource extends Resource

@export var title: String = "Room"
@export var description: String = "Description"
@export var weight: int = 10  # Used for weighted random selection
@export var min_floor: int = 0  # Minimum floor where this room can appear
@export var max_floor: int = -1  # Maximum floor where this room can appear
var cleared_by_default: bool = false  # Whether room is considered cleared immediately when entered

# Virtual method to be overridden by subclasses
# Called when room actions are built
func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    pass

# Virtual method to be overridden by subclasses
# Called when room is entered/generated
func on_room_entered(_room_screen: RoomScreen) -> void:
    pass

# Helper method for subclasses to add action buttons
func add_action_button(actions_grid: GridContainer, text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    actions_grid.add_child(button)
    button.pressed.connect(callback)
    return button

func _on_mark_cleared(room_screen: RoomScreen) -> void:
    room_screen.mark_cleared()

func valid_for_floor(_floor: int) -> bool:
    if _floor < min_floor:
        return false
    if max_floor >= 0 and _floor > max_floor:
        return false
    return true