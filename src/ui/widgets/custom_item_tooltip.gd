class_name CustomItemTooltip extends Control

## Custom tooltip component for displaying item information with rich formatting
##
## This component provides a visually appealing tooltip for items with
## proper layout, spacing, and formatting according to the design specification.

@onready var item_name_label: Label = %ItemName
@onready var item_type_label: Label = %ItemType
@onready var description_label: Label = %Description
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var stats_separator: HSeparator = %StatsSeparator
@onready var condition_label: Label = %ConditionLabel
@onready var sell_value_label: Label = %SellValue

var current_item: Item
var current_count: int = 1
var current_item_data: ItemData = null  # ItemData for the item instance
var setup_pending: bool = false

func _ready() -> void:
    if setup_pending:
        _update_display()

static func get_scene() -> PackedScene:
    return preload("uid://bhlr1m3q7ixjg") as PackedScene

## Setup the tooltip with item data
func setup_tooltip(item: Item, count: int = 1, item_data: ItemData = null) -> void:
    current_item = item
    current_count = count
    current_item_data = item_data

    if not item:
        hide()
        return

    # If nodes are ready, update immediately. Otherwise, defer to _ready()
    if is_node_ready():
        _update_display()
        show()
    else:
        setup_pending = true

## Update all tooltip display elements
func _update_display() -> void:
    if not current_item:
        return

    # Ensure all nodes are ready before updating
    if not is_node_ready():
        return

    _update_item_name()
    _update_item_type()
    _update_description()
    _update_stats()
    _update_condition_label()
    _update_gold_value()

    # Size the tooltip to fit its content
    call_deferred("_size_to_content")
    show()

## Size the tooltip to fit its content
func _size_to_content() -> void:
    # Get the VBoxContainer to measure its content
    var vbox := get_node("MarginContainer/VBoxContainer") as VBoxContainer
    if not vbox:
        return

    # Force a layout update
    vbox.queue_sort()
    await get_tree().process_frame

    # Calculate required size based on content
    var content_size := vbox.get_combined_minimum_size()
    var margin_size := Vector2(16, 12)  # 8px margin on each side

    # Set the tooltip size
    var final_size := content_size + margin_size
    final_size.x = max(final_size.x, 200)  # Minimum width
    final_size.x = min(final_size.x, 400)  # Maximum width
    final_size.y = min(final_size.y, 300)  # Maximum height

    custom_minimum_size = final_size
    size = final_size

## Update the item name display
func _update_item_name() -> void:
    if not item_name_label:
        return

    if current_count > 1:
        item_name_label.text = "%s (%d)" % [current_item.name, current_count]
    else:
        item_name_label.text = current_item.name

## Update the item type display
func _update_item_type() -> void:
    if not item_type_label:
        return
    var type_text := ""
    if current_item is Weapon:
        type_text = "(Weapon"
        if GameState.player.equipped_weapon == current_item:
            type_text += " - Equipped)"
        else:
            type_text += ")"
    elif current_item is Armor:
        var armor := current_item as Armor
        type_text = "(%s" % armor.get_equip_slot_name()
        # Check if this armor is equipped
        var equipped_armor := GameState.player.get_equipped_armor(armor.get_equip_slot())
        if equipped_armor and equipped_armor.item == current_item:
            type_text += " - Equipped)"
        else:
            type_text += ")"
    elif current_item is ItemPotion:
        type_text = "(Potion)"
    elif current_item.get_consumable():
        type_text = "(Consumable)"
    if type_text != "":
        item_type_label.text = type_text

## Update the description display
func _update_description() -> void:
    if not description_label:
        return

    var description := current_item.get_description()
    if description and description.strip_edges() != "":
        description_label.text = description
        description_label.show()
        # Ensure proper wrapping for long descriptions
        description_label.custom_minimum_size.x = 180
    else:
        description_label.hide()

## Update the stats display (weapon damage, potion effects, etc.)
func _update_stats() -> void:
    # Clear existing stats
    for child in stats_container.get_children():
        child.queue_free()

    var additional_tooltip_infos := current_item.get_additional_tooltip_info()
    for additional_tooltip_info in additional_tooltip_infos:
        var info_label := Label.new()
        info_label.text = additional_tooltip_info.text
        info_label.add_theme_font_size_override("font_size", 16)
        info_label.modulate = additional_tooltip_info.color
        info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        info_label.custom_minimum_size.x = 180
        stats_container.add_child(info_label)

    # Show/hide stats container based on content
    stats_container.visible = stats_container.get_child_count() > 0
    stats_separator.visible = stats_container.visible

func _update_condition_label() -> void:
    if not condition_label:
        return
    if current_item is Equippable:
        var equippable_item: Equippable = current_item as Equippable
        var current_condition := equippable_item.condition
        var max_condition := equippable_item.get_max_condition()

        # Override with item data if available
        if current_item_data and "current_condition" in current_item_data:
            current_condition = current_item_data.current_condition

        condition_label.text = "🛠️ Condition: %d/%d" % [current_condition, max_condition]
        condition_label.show()
    else:
        condition_label.hide()


## Update the sell value display
func _update_gold_value() -> void:
    if not sell_value_label:
        return
    var sell_value := current_item.calculate_sell_value(current_item_data)
    sell_value_label.text = "🪙 %d gold" % sell_value
