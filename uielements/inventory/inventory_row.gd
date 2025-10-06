class_name InventoryRow extends Control

## Component for displaying a single inventory item with inline action button
##
## This component encapsulates the display and interaction logic for individual
## inventory items, including selection highlighting and inline Use/Equip buttons.

signal item_selected(item: Item)
signal item_used(item: Item)

# Preload the custom tooltip scene
const CUSTOM_TOOLTIP_SCENE = preload("res://uielements/CustomItemTooltip.tscn")

@onready var background: Panel = %Background
@onready var item_name_label: Label = %ItemName
# @onready var item_desc_label: Label = %ItemDescription
@onready var action_button: Button = %ActionButton

var item_resource: Item
var count: int
var is_selected: bool = false
var is_combat_disabled: bool = false

func _ready() -> void:
    # Connect the background click for selection
    background.gui_input.connect(_on_background_input)
    action_button.pressed.connect(_on_action_button_pressed)

    _update_display()
    _update_action_button()

## Setup the row with item data
func setup(_item_resource: Item, _count: int, _is_combat_disabled: bool = false) -> void:
    item_resource = _item_resource
    count = _count
    is_combat_disabled = _is_combat_disabled
    print("Setting up inventory row for: ", item_resource.name if item_resource else "none")

    if is_node_ready():
        _update_display()
        _update_action_button()
        _update_background()  # Ensure background is updated on setup

## Set the selection state of this row
func set_selected(selected: bool) -> void:
    is_selected = selected
    _update_background()

## Set whether combat is disabled (affects button availability)
func set_combat_disabled(disabled: bool) -> void:
    is_combat_disabled = disabled
    _update_action_button()

func _update_display() -> void:
    if not item_resource:
        tooltip_text = ""
        return

    var item_text = item_resource.name + " x%d" % count

    item_name_label.text = item_text
    # item_desc_label.text = item_resource.get_description()

    # Set simple tooltip text to trigger custom tooltip system
    tooltip_text = item_resource.name

    # Update background after display update
    _update_background()

func _update_action_button() -> void:
    if not item_resource:
        return

    action_button.disabled = is_combat_disabled

    if item_resource is ItemWeapon:
        # Weapons can always be equipped/unequipped
        action_button.disabled = false
        if GameState.player.equipped_weapon == item_resource:
            action_button.text = "Unequip"
        else:
            action_button.text = "Equip"
    else:
        action_button.text = "Use"

func _update_background() -> void:
    # Create a StyleBoxFlat for custom background colors
    var style_box = StyleBoxFlat.new()

    # Check if item is equipped first (highest priority)
    if item_resource is ItemWeapon and GameState.player.equipped_weapon == item_resource:
        # Use a proper bright green
        style_box.bg_color = Color(0.2, 0.4, 0.2)  # Bright green
        background.add_theme_stylebox_override("panel", style_box)
        print("Setting equipped background for: ", item_resource.name)
    elif is_selected:
        # Selection highlight - light blue
        style_box.bg_color = Color(0.6, 0.8, 1.0)  # Light blue
        background.add_theme_stylebox_override("panel", style_box)
        print("Setting selected background for: ", item_resource.name)
    else:
        # Default state - remove override to use theme default
        background.remove_theme_stylebox_override("panel")
        print("Setting default background for: ", item_resource.name if item_resource else "none")

func _on_background_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        item_selected.emit(item_resource)

func _on_action_button_pressed() -> void:
    if item_resource:
        item_used.emit(item_resource)

## Override to provide custom tooltip
func _make_custom_tooltip(_for_text: String) -> Control:
    if not item_resource:
        return null

    var tooltip = CUSTOM_TOOLTIP_SCENE.instantiate()
    tooltip.setup_tooltip(item_resource, count)
    return tooltip
