class_name ItemSelectionPopup extends Control

signal item_selected(item: ItemInstance)
signal cancelled

@onready var background: ColorRect = %Background
@onready var title_label: Label = %TitleLabel
@onready var item_list: VBoxContainer = %ItemList
@onready var cancel_button: Button = %CancelButton
@onready var scroll_container: ScrollContainer = %ScrollContainer

## The scrollbar height at which it switches to scroll mode
@export var max_scroll_height: float = 250.0

var available_items: Array[ItemInstance] = []
var popup_title: String = ""
var show_condition: bool = false
var show_equipped: bool = true

func _ready() -> void:
    cancel_button.pressed.connect(_on_cancel_pressed)
    # Close when clicking outside
    background.gui_input.connect(_on_background_input)

    # Ensure popup accepts input
    mouse_filter = Control.MOUSE_FILTER_STOP

    # Setup scroll container
    scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

    # Connect to item list changes to update scroll behavior
    if item_list:
        item_list.resized.connect(_update_scroll_size)

    # Apply any setup that was called before _ready()
    if not popup_title.is_empty():
        title_label.text = popup_title
    if not available_items.is_empty():
        _populate_item_list()

func setup(title: String, items: Array[ItemInstance]) -> void:
    popup_title = title
    available_items = items

    # If the node is already ready, apply immediately
    if is_node_ready():
        title_label.text = popup_title
        _populate_item_list()

func _populate_item_list() -> void:
    # Clear existing items
    for child in item_list.get_children():
        child.queue_free()

    if available_items.is_empty():
        var no_items_label := Label.new()
        no_items_label.text = "No suitable items found."
        no_items_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        item_list.add_child(no_items_label)
        _update_scroll_size()
        return

    # Add buttons for each available item
    for item_instance: ItemInstance in available_items:
        var button := Button.new()
        button.text = item_instance.item.name
        if show_condition and item_instance.item_data and item_instance.item is Equippable:
            var equippable := item_instance.item as Equippable
            var condition_text := " (%d/%d)" % [item_instance.item_data.current_condition, equippable.get_max_condition()]
            button.text += condition_text

        if show_equipped and item_instance.is_equipped:
            # button.text += " (Equipped)"
            button.modulate = Color(0.7, 0.9, 0.7)  # Light green for equipped items

        button.pressed.connect(_on_item_button_pressed.bind(item_instance))
        item_list.add_child(button)

    # Update scroll size after populating
    call_deferred("_update_scroll_size")

func _update_scroll_size() -> void:
    if not scroll_container or not item_list:
        return

    # Wait one frame for layout to be calculated
    await get_tree().process_frame

    var content_height := item_list.get_minimum_size().y

    if content_height <= max_scroll_height:
        # Fit to content - no scrolling needed
        scroll_container.custom_minimum_size.y = content_height
        scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    else:
        # Enable scrolling
        scroll_container.custom_minimum_size.y = max_scroll_height
        scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

func _on_item_button_pressed(item: ItemInstance) -> void:
    item_selected.emit(item)
    _cleanup_popup()

func _on_cancel_pressed() -> void:
    cancelled.emit()
    _cleanup_popup()

func _cleanup_popup() -> void:
    # Just remove this popup - PopupLayer is persistent and should not be deleted
    queue_free()

func _on_background_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
            _on_cancel_pressed()

func show_popup() -> void:
    # This method is now handled by UIManager - kept for compatibility
    visible = true
