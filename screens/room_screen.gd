class_name RoomScreen extends Control

signal room_cleared
signal run_ended(victory: bool)

var available_rooms: Array[RoomResource] = []

@export var starting_rooms: Array[RoomResource] = []

@onready var floor_label: Label = %FloorLabel
@onready var hp_label: Label = %HPLabel
@onready var hp_bar: ProgressBar = %HPBar
@onready var atk_value: Label = %AtkValue
@onready var def_value: Label = %DefValue
@onready var gold_value: Label = %GoldValue
@onready var buffs_block: Container = %BuffsBlock
@onready var inventory_component: InventoryComponent = %InventoryComponent
@onready var log_label: RichTextLabel = %Log
@onready var actions_grid: GridContainer = %Actions
@onready var next_btn: Button = %NextFloorBtn
@onready var leave_btn: Button = %LeaveRunBtn
@onready var room_title: Label = %RoomTitle
@onready var room_desc: Label = %RoomDescription

var current_room: RoomResource
var cleared: bool = false

# Combat state management
var is_in_combat: bool = false
var current_enemy: Enemy = null
var enemy_resource: EnemyResource = null
var enemy_first: bool = false
var avoid_failure: bool = false
var stored_room_actions: Array[Button] = []  # Store original room actions
static var recent_room_history: Array[RoomResource] = []  # Track recent room class names
var max_history_size: int = 3  # How many recent rooms to remember
var weight_penalty: float = 0.01  # Multiplier for recently used rooms (0.3 = 30% of original weight)

func _ready() -> void:
    print("RoomScreen ready")

    # Get all rooms from resources/rooms
    _load_all_rooms()

    GameState.stats_changed.connect(_on_stats_changed)
    GameState.run_ended.connect(func(v: bool) -> void: emit_signal("run_ended", v))

    # Connect inventory component signals
    inventory_component.item_used.connect(_on_item_used)
    inventory_component.inventory_updated.connect(_on_inventory_updated)

    # Connect to child_entered_tree to detect when combat popups are added
    child_entered_tree.connect(_on_child_added)
    child_exiting_tree.connect(_on_child_removed)

    next_btn.disabled = true
    _refresh_stats()
    _refresh_buffs()

    # Register log display with LogManager for automatic updates
    LogManager.register_log_display(log_label)

    _generate_room()

    next_btn.pressed.connect(func() -> void:
        if cleared:
            emit_signal("room_cleared"))
    leave_btn.pressed.connect(_on_leave_run_pressed)

func _load_all_rooms() -> void:
    """Automatically load all room resources from resources/rooms directory"""
    available_rooms.clear()

    var dir := DirAccess.open("res://resources/rooms/")
    if dir:
        dir.list_dir_begin()
        var file_name := dir.get_next()
        var file_names: Array[String] = []

        # Collect all .tres files first
        while file_name != "":
            if file_name.ends_with(".tres"):
                file_names.append(file_name)
            file_name = dir.get_next()

        dir.list_dir_end()

        # Sort files for consistent loading order
        file_names.sort()

        # Load all room resources
        for file in file_names:
            var resource_path := "res://resources/rooms/" + file
            var room_resource := load(resource_path) as RoomResource

            if room_resource:
                available_rooms.append(room_resource)
                print("Loaded room: ", file, " (", room_resource.title, ")")
            else:
                print("Warning: Failed to load room resource: ", file)

        print("Total rooms loaded: ", available_rooms.size())

        if available_rooms.is_empty():
            print("Warning: No rooms were loaded from resources/rooms/")
    else:
        print("Error: Failed to open resources/rooms directory")

# Public method to reload all rooms (useful for development)
func reload_rooms() -> void:
    """Reload all room resources from the resources/rooms directory"""
    _load_all_rooms()

# Call this to refresh all UI elements
func update() -> void:
    _refresh_stats()
    _refresh_buffs()
    inventory_component.refresh()

# Called when stats change (including status effect changes)
func _on_stats_changed() -> void:
    _refresh_stats()
    _refresh_buffs()  # Also refresh buffs since status effects are shown there

func _refresh_stats() -> void:
    floor_label.text = "FLOOR: %d" % GameState.current_floor
    hp_label.text = "HP: %d/%d" % [GameState.player.get_hp(), GameState.player.get_max_hp()]
    hp_bar.max_value = GameState.player.get_max_hp()
    hp_bar.value = GameState.player.get_hp()
    gold_value.text = str(GameState.player.gold)

    # Update HP bar tooltip to show buff information
    var buff_info := ""
    var attack_bonus := GameState.player.get_total_attack_bonus()
    var defense_bonus := GameState.player.get_total_defense_bonus()

    if attack_bonus > 0 or defense_bonus > 0:
        buff_info = " (ATK +%d, DEF +%d)" % [attack_bonus, defense_bonus]

    # Add status effects count and tooltip
    var active_effects := GameState.get_player_status_effects()
    var hp_tooltip_text := "HP: %d/%d%s" % [GameState.player.get_hp(), GameState.player.get_max_hp(), buff_info]

    if active_effects.size() > 0:
        var effects_text := "\nActive Status Effects (%d):" % active_effects.size()
        for effect in active_effects:
            effects_text += "\n• %s" % effect.get_description()
        hp_tooltip_text += effects_text

    hp_bar.tooltip_text = hp_tooltip_text

    atk_value.text = "ATK: %s" % GameState.player.get_total_attack_display()
    def_value.text = "DEF: %s" % GameState.player.get_total_defense_bonus()


func _refresh_buffs() -> void:
    # Clear existing StatusRow instances immediately
    for child in buffs_block.get_children():
        if child is StatusRow:
            buffs_block.remove_child(child)
            child.queue_free()

    var has_content := false

    # Add status effects
    var status_effects := GameState.get_player_status_effects()
    if status_effects.size() > 0:
        has_content = true
        print("Adding %d status effects" % status_effects.size())
        for effect in status_effects:
            var status_row := StatusRow.new()
            buffs_block.add_child(status_row)
            status_row.initialize_with_status_effect(effect)
            print("Added effect StatusRow, children count: %d" % buffs_block.get_child_count())

    # Handle display logic
    if not has_content:
        print("No buffs or effects, adding 'None' row")
        # Show "None" message when no buffs/effects
        var none_row := StatusRow.new()
        buffs_block.add_child(none_row)
        none_row.bbcode_enabled = true
        none_row.clear()
        none_row.append_text("[color=gray]None[/color]")
        none_row.tooltip_text = "No active buffs or status effects"
        buffs_block.visible = true
        print("Added 'None' row, children count: %d" % buffs_block.get_child_count())
    else:
        buffs_block.visible = true
        print("Buffs block visible with %d children" % buffs_block.get_child_count())

# Inventory component callbacks
func _on_item_used() -> void:
    update()

func _on_inventory_updated() -> void:
    # Update inventory component combat state when needed
    inventory_component.set_combat_disabled(is_in_combat)


func _calculate_room_weights(valid_rooms: Array[RoomResource]) -> Array[float]:
    var weights: Array[float] = []
    for room in valid_rooms:
        var base_weight := float(room.weight)
        # Apply penalty each time this room type appears in recent history
        for recent_room in recent_room_history:
            if recent_room == room:
                base_weight *= weight_penalty
        weights.append(base_weight)
    return weights

func _generate_room() -> void:

    var num_starting_rooms := starting_rooms.size()
    if num_starting_rooms > 0 and num_starting_rooms > GameState.current_floor - 1:
        current_room = starting_rooms[GameState.current_floor - 1]
        print("Selected starting room for floor %d: %s" % [GameState.current_floor, current_room.title])
        current_room.on_room_entered(self)
        _render_room()
        return

    var valid_rooms : Array[RoomResource] = []
    for room in available_rooms:
        if room.valid_for_floor(GameState.current_floor):
            valid_rooms.append(room)

    # Calculate adjusted weights based on recent history
    print("=== Room Generation Debug ===")
    print("Recent room history: ", recent_room_history)
    print("Weight penalty: ", weight_penalty)

    var adjusted_weights:= _calculate_room_weights(valid_rooms)
    var total_weight := 0.0
    for w in adjusted_weights:
        total_weight += w

    print("Total weight: ", total_weight)
    print("Adjusted weights: ", adjusted_weights)


    # Weighted random selection using adjusted weights
    var random_value := GameState.rng.randf_range(0.0, total_weight)
    var current_weight := 0.0

    for i in range(valid_rooms.size()):
        current_weight += adjusted_weights[i]
        if random_value <= current_weight:
            current_room = valid_rooms[i]
            break

    if current_room:
        # Track this room type in history
        recent_room_history.append(current_room)

        # Keep history within size limit
        while recent_room_history.size() > max_history_size:
            recent_room_history.pop_front()

        current_room.on_room_entered(self)
        _render_room()

func _render_room() -> void:
    if not current_room:
        return

    room_title.text = current_room.title
    room_desc.text = current_room.description
    _build_actions()

    # Check if room should be cleared by default
    if current_room.cleared_by_default:
        _mark_cleared_by_default()

func _build_actions() -> void:
    for c in actions_grid.get_children():
        c.queue_free()

    if current_room:
        current_room.build_actions(actions_grid, self)

func _mark_cleared() -> void:
    print("Room marked as cleared")
    cleared = true
    next_btn.disabled = false

    # Disable all action buttons when room is cleared
    for child in actions_grid.get_children():
        if child is Button:
            (child as Button).disabled = true

    if not current_room.cleared_by_default:
        LogManager.log_success("Room cleared! Proceed when ready.")

func _mark_cleared_by_default() -> void:
    print("Room cleared by default")
    cleared = true
    next_btn.disabled = false

# Public method that room resources can call
func mark_cleared() -> void:
    _mark_cleared()

func _on_child_added(node: Node) -> void:
    # Update UI when combat popup is added
    if node is CombatPopup:
        is_in_combat = true
        inventory_component.set_combat_disabled(true)
        update()

func _on_child_removed(node: Node) -> void:
    # Update UI when combat popup is removed
    if node is CombatPopup:
        is_in_combat = false
        inventory_component.set_combat_disabled(false)
        update()

func _exit_tree() -> void:
    # Unregister log display when room screen is destroyed
    if log_label:
        LogManager.unregister_log_display(log_label)

func _on_leave_run_pressed() -> void:
    """Show confirmation popup before leaving the run"""
    var confirmation_popup: ConfirmationPopup = (load("res://popups/ConfirmationPopup.tscn") as PackedScene).instantiate()
    add_child(confirmation_popup)

    confirmation_popup.show_confirmation("Are you sure you want to leave this run?")

    # Connect signals
    confirmation_popup.confirmed.connect(func() -> void:
        GameState.emit_signal("run_ended", false))
    confirmation_popup.cancelled.connect(func() -> void:
        pass)  # Do nothing, popup will close automatically
