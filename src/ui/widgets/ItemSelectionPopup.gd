class_name ItemSelectionPopup extends Control

signal item_selected(item: ItemInstance)
signal cancelled

@onready var background: ColorRect = %Background
@onready var title_label: Label = %TitleLabel
@onready var item_list: VBoxContainer = %ItemList
@onready var cancel_button: Button = %CancelButton

var available_items: Array[ItemInstance] = []
var popup_title: String = ""

func _ready() -> void:
    cancel_button.pressed.connect(_on_cancel_pressed)
    # Close when clicking outside
    background.gui_input.connect(_on_background_input)

    # Ensure popup accepts input
    mouse_filter = Control.MOUSE_FILTER_STOP

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
        return

    # Add buttons for each available item
    for item_instance: ItemInstance in available_items:
        var button := Button.new()
        button.text = item_instance.item.name
        if item_instance.item_data and item_instance.item is Equippable:
            var equippable := item_instance.item as Equippable
            var condition_text := " (%d/%d)" % [item_instance.item_data.current_condition, equippable.get_max_condition()]
            button.text += condition_text

        button.pressed.connect(_on_item_button_pressed.bind(item_instance))
        item_list.add_child(button)

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
