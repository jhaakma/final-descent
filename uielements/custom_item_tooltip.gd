class_name CustomItemTooltip extends Control

## Custom tooltip component for displaying item information with rich formatting
##
## This component provides a visually appealing tooltip for items with
## proper layout, spacing, and formatting according to the design specification.

@onready var item_name_label: Label = %ItemName
@onready var item_type_label: Label = %ItemType
@onready var description_label: Label = %Description
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var sell_value_label: Label = %SellValue

var current_item: Item
var current_count: int = 1
var setup_pending: bool = false

func _ready() -> void:
    if setup_pending:
        _update_display()

## Setup the tooltip with item data
func setup_tooltip(item: Item, count: int = 1) -> void:
    current_item = item
    current_count = count

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
    _update_gold_value()

    # Size the tooltip to fit its content
    call_deferred("_size_to_content")
    show()

## Size the tooltip to fit its content
func _size_to_content() -> void:
    # Get the VBoxContainer to measure its content
    var vbox = get_node("MarginContainer/VBoxContainer") as VBoxContainer
    if not vbox:
        return

    # Force a layout update
    vbox.queue_sort()
    await get_tree().process_frame

    # Calculate required size based on content
    var content_size = vbox.get_combined_minimum_size()
    var margin_size = Vector2(16, 12)  # 8px margin on each side

    # Set the tooltip size
    var final_size = content_size + margin_size
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
        item_name_label.text = "%s x%d" % [current_item.name, current_count]
    else:
        item_name_label.text = current_item.name

## Update the item type display
func _update_item_type() -> void:
    if not item_type_label:
        return

    var type_text = ""

    if current_item is ItemWeapon:
        type_text = "(Weapon"
        if GameState.player.equipped_weapon == current_item:
            type_text += " - Equipped)"
        else:
            type_text += ")"
    elif current_item is ItemPotion:
        type_text = "(Potion"
        if current_item.consumable:
            type_text += " - Consumable)"
        else:
            type_text += ")"
    else:
        if current_item.consumable:
            type_text = "(Consumable)"
        else:
            type_text = "(Reusable)"

    item_type_label.text = type_text

## Update the description display
func _update_description() -> void:
    if not description_label:
        return

    var description = current_item.get_description()
    if description and description.strip_edges() != "":
        description_label.text = description
        description_label.show()
        # Ensure proper wrapping for long descriptions
        description_label.custom_minimum_size.x = 180
    else:
        description_label.hide()

## Update the stats display (weapon damage, potion effects, etc.)
func _update_stats() -> void:
    if not stats_container:
        return

    # Clear existing stats
    for child in stats_container.get_children():
        child.queue_free()

    # Add weapon-specific stats
    if current_item is ItemWeapon:
        var weapon = current_item as ItemWeapon
        var damage_label = Label.new()
        damage_label.text = "⚔️ Damage: %d" % weapon.damage
        damage_label.add_theme_font_size_override("font_size", 10)
        damage_label.modulate = Color(1.0, 0.8, 0.6)
        stats_container.add_child(damage_label)

    # Add potion-specific stats
    if current_item is ItemPotion:
        var potion = current_item as ItemPotion
        if potion.effect:
            var effect_label = Label.new()
            effect_label.text = "✨ Effect: %s" % potion.effect.get_description()
            effect_label.add_theme_font_size_override("font_size", 10)
            effect_label.modulate = Color(0.6, 1.0, 0.8)
            effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            stats_container.add_child(effect_label)

    # Show/hide stats container based on content
    stats_container.visible = stats_container.get_child_count() > 0

## Update the sell value display
func _update_gold_value() -> void:
    if not sell_value_label:
        return
    sell_value_label.text = "🪙 Value: %d gold" % current_item.purchase_value
