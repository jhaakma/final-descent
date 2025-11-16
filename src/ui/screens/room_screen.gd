class_name RoomScreen extends Control

signal room_cleared
signal run_ended(victory: bool)

var available_rooms: Array[RoomResource] = []

## Manually specify all room resources for web export compatibility
## When this array is populated, it will be used instead of dynamic directory scanning
@export var all_rooms: Array[IRoomTemplate] = []

@onready var floor_label: Label = %FloorLabel
@onready var hp_label: Label = %HPLabel
@onready var hp_bar: ProgressBar = %HPBar
@onready var atk_value: Label = %AtkValue
@onready var def_value: Label = %DefValue
@onready var gold_value: Label = %GoldValue
@onready var buffs_block: Container = %BuffsBlock
@onready var inventory_component: InventoryContainer = %InventoryContainer
@onready var log_label: RichTextLabel = %Log
@onready var inline_content_container: VBoxContainer = %InlineContentContainer
@onready var actions_grid: GridContainer = %Actions
@onready var actions_container: VBoxContainer = %ActionsContainer
@onready var room_title: Label = %RoomTitle
@onready var room_desc: Label = %RoomDescription
@onready var next_btn: Button = %NextFloorBtn
@onready var leave_btn: Button = %LeaveRunBtn

var current_room: RoomResource
var cleared: bool = false

# Inline content system
var current_inline_content: Control = null

# Combat state management
var is_in_combat: bool = false
var current_enemy: Enemy = null
var enemy_resource: EnemyResource = null
var enemy_first: bool = false
var avoid_failure: bool = false
var stored_room_actions: Array[Button] = []  # Store original room actions
var max_history_size: int = 3  # How many recent rooms to remember
var weight_penalty: float = 0.01  # Multiplier for recently used rooms (0.3 = 30% of original weight)


static func get_scene() -> PackedScene:
    return preload("uid://c0cpy5xfdy2nb") as PackedScene

func _ready() -> void:
    print("RoomScreen ready")


    # Connect to centralized UI event bus
    UIEvents.player_stats_changed.connect(_on_stats_changed)
    UIEvents.player_status_effects_changed.connect(_on_status_effects_changed)
    UIEvents.player_inventory_changed.connect(_on_inventory_updated)
    UIEvents.ui_refresh_requested.connect(update)

    # Keep legacy GameState connection for backward compatibility
    GameState.stats_changed.connect(_on_stats_changed)
    GameState.run_ended.connect(func(v: bool) -> void: emit_signal("run_ended", v))

    # Connect inventory component signals
    inventory_component.item_used.connect(_on_item_used)
    inventory_component.inventory_updated.connect(_on_inventory_updated)

    next_btn.disabled = true
    _refresh_stats()
    _refresh_buffs()

    # Register log display with LogManager for automatic updates
    LogManager.register_log_display(log_label)

    _initialize_stage_plan()

    _generate_room()

    next_btn.pressed.connect(func() -> void:
        if cleared:
            emit_signal("room_cleared"))
    leave_btn.pressed.connect(_on_leave_run_pressed)



func _initialize_stage_plan() -> void:
    """Initialize stage plan if StageManager doesn't have one yet"""
    if StageManager.has_stage_plan():
        print("Stage plan already exists, skipping initialization")
        return

    var current_stage := StageManager.get_current_stage()

    var template : StageTemplateResource = StageTemplateResource.new()

    # Generate stage instance
    var rng_seed := GameState.rng.seed
    var stage_instance := StageGenerator.generate(
        current_stage,
        template,
        rng_seed,
        all_rooms,
    )

    if not stage_instance.integrity_ok:
        push_error("Stage generation had integrity issues")

    # Set the stage instance in StageManager
    StageManager.set_stage_instance(stage_instance)
    print("Stage plan initialized: %d rooms planned" % stage_instance.planned_rooms.size())

    # Debug: Print planned rooms
    for i in range(stage_instance.planned_rooms.size()):
        var room := stage_instance.planned_rooms[i]
        print("  Floor %d: %s (%s)" % [i + 1, room.title, RoomType.get_display_name(room.room_type)])

# Call this to refresh all UI elements
func update() -> void:
    _refresh_stats()
    _refresh_buffs()
    inventory_component.refresh()

# Called when stats change (including status effect changes)
func _on_stats_changed() -> void:
    _refresh_stats()
    _refresh_buffs()  # Also refresh buffs since status effects are shown there

# Called specifically when status effects change (via UIEvents)
func _on_status_effects_changed() -> void:
    _refresh_buffs()  # Only refresh the status effects display

func _refresh_stats() -> void:
    # Show stage and floor information with boss indicator
    var stage_info := StageManager.get_debug_info() if StageManager else "FLOOR: %d" % GameState.current_floor
    floor_label.text = stage_info

    hp_label.text = "HP: %d/%d" % [GameState.player.get_hp(), GameState.player.get_max_hp()]
    hp_bar.max_value = GameState.player.get_max_hp()
    hp_bar.value = GameState.player.get_hp()
    gold_value.text = str(GameState.player.gold)

    # Update HP bar tooltip to show buff information
    var buff_info := ""
    var attack_bonus := GameState.player.get_attack_bonus()
    var current_def_tooltip := GameState.player.get_defense_bonus()

    if attack_bonus > 0 or current_def_tooltip > 0:
        buff_info = " (ATK +%d, DEF %d%%)" % [attack_bonus, current_def_tooltip]

    # Add status conditions count and tooltip
    var active_conditions: Array[StatusCondition] = GameState.player.get_all_status_conditions()
    var hp_tooltip_text := "HP: %d/%d%s" % [GameState.player.get_hp(), GameState.player.get_max_hp(), buff_info]

    if active_conditions.size() > 0:
        var cond_text := "\nActive Status Conditions (%d):" % active_conditions.size()
        for condition: StatusCondition in active_conditions:
            cond_text += "\n• %s" % condition.get_description()
        hp_tooltip_text += cond_text

    hp_bar.tooltip_text = hp_tooltip_text

    atk_value.text = "ATK: %s" % GameState.player.get_total_attack_display()

    # Show current effective defense (including defend bonus if defending)
    var current_def := GameState.player.get_defense_bonus()
    var defend_bonus := GameState.player.get_defend_bonus_percentage()

    if defend_bonus > 0:
        def_value.text = "DEF: %d%% (+%d%% defending)" % [current_def, defend_bonus]
    else:
        def_value.text = "DEF: %d%%" % current_def


func _refresh_buffs() -> void:
    # Clear existing StatusRow instances immediately
    for child in buffs_block.get_children():
        if child is StatusRow:
            buffs_block.remove_child(child)
            child.queue_free()

    var has_content := false

    # Add status conditions
    var status_conditions: Array[StatusCondition] = GameState.player.get_all_status_conditions()
    if status_conditions.size() > 0:
        has_content = true
        print("Adding %d status conditions" % status_conditions.size())
        for condition: StatusCondition in status_conditions:
            var status_row := StatusRow.get_scene().instantiate() as StatusRow
            buffs_block.add_child(status_row)
            status_row.initialize_with_condition(condition)
            print("Added condition StatusRow, children count: %d" % buffs_block.get_child_count())

    # Handle display logic
    if not has_content:
        print("No buffs or conditions, adding 'None' row")
        # Show "None" message when no buffs/conditions
        var none_row := StatusRow.get_scene().instantiate() as StatusRow
        buffs_block.add_child(none_row)
        none_row.status_text.text = "[color=gray]None[/color]"
        none_row.status_value.text = ""
        none_row.tooltip_text = "No active buffs or status conditions"
        buffs_block.visible = true
        print("Added 'None' row, children count: %d" % buffs_block.get_child_count())
    else:
        buffs_block.visible = true
        print("Buffs block visible with %d children" % buffs_block.get_child_count())

# Inventory component callbacks
func _on_item_used(_item_tile: ItemInstance) -> void:
    # If in combat, trigger combat turn
    if is_in_combat:
        _trigger_combat_turn()
    update()

func _on_inventory_updated() -> void:
    # No need to disable inventory during combat - items can be used
    pass

func _is_consumable_item(item: Item) -> bool:
    """Check if an item is consumable (not a weapon - weapons don't consume turns)"""
    return not (item is Weapon)

func _trigger_combat_turn() -> void:
    """Trigger the combat turn when a consumable item is used during combat"""
    if current_inline_content and current_inline_content.has_method("handle_item_used"):
        current_inline_content.call("handle_item_used")


func _generate_room() -> void:
    var planned_room := StageManager.get_current_planned_room()
    if planned_room:
        current_room = planned_room
        print("Using planned room for floor %d: %s" % [GameState.current_floor, current_room.title])
        current_room.on_room_entered(self)
        _render_room()
        return
    else:
        push_error("Stage plan exists but returned null room at floor %d" % GameState.current_floor)
        # Fall through to legacy generation

func _render_room() -> void:
    if not current_room:
        return

    room_title.text = current_room.title
    room_desc.text = current_room.description
    _build_actions()

    # Check if room should be cleared by default
    if current_room.is_cleared_by_default():
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

    if not current_room.is_cleared_by_default():
        LogManager.log_success("Room cleared! Proceed when ready.")

func _mark_cleared_by_default() -> void:
    print("Room cleared by default")
    cleared = true
    next_btn.disabled = false

# Public method that room resources can call
func mark_cleared() -> void:
    _mark_cleared()

# === Inline Content Management ===

func show_inline_content(content: Control) -> void:
    """Replace the room container with inline content"""
    # Hide room content
    actions_container.visible = false

    # Clear any existing inline content (without restoring room container)
    if current_inline_content:
        _clear_inline_content_only()

    # Add and show new content
    inline_content_container.add_child(content)
    inline_content_container.visible = true

    # Store reference and initialize if available
    current_inline_content = content
    if content.has_method("initialize"):
        content.call("initialize", self)

    # Connect signals using string-based connection (safer for dynamic types)
    if content.has_signal("content_resolved"):
        content.connect("content_resolved", _on_inline_content_resolved)
    if content.has_signal("content_closed"):
        content.connect("content_closed", _on_inline_content_closed)

    # Check if this is combat content and update combat state
    if content is InlineCombat:
        is_in_combat = true
        update()

    # Call show_content if the method exists
    if content.has_method("show_content"):
        content.call("show_content")

func _clear_inline_content_only() -> void:
    """Clear inline content without restoring room container - used when replacing inline content"""
    if current_inline_content and is_instance_valid(current_inline_content):
        # Disconnect signals
        if current_inline_content.has_signal("content_resolved"):
            current_inline_content.disconnect("content_resolved", _on_inline_content_resolved)
        if current_inline_content.has_signal("content_closed"):
            current_inline_content.disconnect("content_closed", _on_inline_content_closed)

        # Cleanup if method exists
        if current_inline_content.has_method("cleanup"):
            current_inline_content.call("cleanup")
        current_inline_content = null

    # Clear the inline container
    for child in inline_content_container.get_children():
        inline_content_container.remove_child(child)
        child.queue_free()

func hide_inline_content() -> void:
    """Hide inline content and restore room container"""
    # Check if we're hiding combat content and reset combat state
    if current_inline_content is InlineCombat:
        is_in_combat = false
        update()

    _clear_inline_content_only()

    # Show room content
    inline_content_container.visible = false
    actions_container.visible = true

func _on_inline_content_resolved() -> void:
    """Called when inline content interaction is complete"""
    hide_inline_content()
    # Usually mark room as cleared when content is resolved
    if not cleared:
        _mark_cleared()

func _on_inline_content_closed() -> void:
    """Called when inline content should be closed"""
    hide_inline_content()



func _exit_tree() -> void:
    # Unregister log display when room screen is destroyed
    if log_label:
        LogManager.unregister_log_display(log_label)

func _on_leave_run_pressed() -> void:
    """Show confirmation popup before leaving the run"""
    var confirmation_popup: ConfirmationPopup = ConfirmationPopup.get_scene().instantiate()
    add_child(confirmation_popup)

    confirmation_popup.show_confirmation("Are you sure you want to leave this run?")

    # Connect signals
    confirmation_popup.confirmed.connect(func() -> void:
        GameState.emit_signal("run_ended", false))
    confirmation_popup.cancelled.connect(func() -> void:
        pass)  # Do nothing, popup will close automatically
