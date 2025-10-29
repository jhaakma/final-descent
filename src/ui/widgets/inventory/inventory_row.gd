class_name InventoryRow extends MarginContainer

## Reusable component for displaying items with action buttons
##
## This component can be used in different contexts (inventory, shop, etc.)
## and adapts its display and functionality based on the display mode.

signal item_selected(item_instance: ItemInstance)
signal item_used(item_instance: ItemInstance)
signal item_bought(item_instance: ItemInstance)
signal item_sold(item_instance: ItemInstance)

enum DisplayMode {
    INVENTORY,   # Show Use/Equip buttons
    EQUIPPED,    # Show Unequip button, no green highlight
    SHOP_BUY,    # Show Buy button with price
    SHOP_SELL    # Show Sell button with price
}

static func get_scene() -> PackedScene:
    return preload("uid://bqmch8xq2h1kp") as PackedScene

# Preload the custom tooltip scene
var custom_tooltip_scene := CustomItemTooltip.get_scene()

@onready var background: Panel = %Background
@onready var item_name_label: Label = %ItemName
@onready var price_label: Label = %PriceLabel
@onready var action_button: Button = %ActionButton
@onready var condition_bar: ProgressBar = %ConditionBar  # Reference to scene element

var item_instance: ItemInstance = null  # Optional ItemInstance reference for context
var is_combat_disabled: bool = false
var display_mode: DisplayMode = DisplayMode.INVENTORY
var shopkeeper_gold: int = 0  # For shop contexts, to determine if items can be afforded

func _ready() -> void:
    # Connect the background click for selection
    background.gui_input.connect(_on_background_input)
    action_button.pressed.connect(_on_action_button_pressed)

    _update_display()
    _update_action_button()

## Setup the row with item data (inventory mode)
func setup(_item_tile: ItemInstance, _is_combat_disabled: bool = false) -> void:
    setup_with_mode(_item_tile, DisplayMode.INVENTORY, _is_combat_disabled, 0)

## Setup the row with custom display name and item data (inventory mode)
func setup_with_custom_name(_item_tile: ItemInstance, _is_combat_disabled: bool, _is_equipped: bool = false) -> void:
    setup_with_mode(item_instance, DisplayMode.INVENTORY, _is_combat_disabled)

## Setup the row for shop context
func setup_for_shop(_item_tile: ItemInstance, _display_mode: DisplayMode, _shopkeeper_gold: int = 0) -> void:
    setup_with_mode(_item_tile,  _display_mode, false, _shopkeeper_gold)

## Internal setup method with all parameters
func setup_with_mode(_item_tile: ItemInstance, _display_mode: DisplayMode, _is_combat_disabled: bool = false, _shopkeeper_gold: int = 0) -> void:
    item_instance = _item_tile
    display_mode = _display_mode
    is_combat_disabled = _is_combat_disabled
    shopkeeper_gold = _shopkeeper_gold

    if is_node_ready():
        _update_display()
        _update_action_button()
        _update_background()
        _update_condition_bar()


## Set whether combat is disabled (affects button availability)
func set_combat_disabled(disabled: bool) -> void:
    is_combat_disabled = disabled
    _update_action_button()

func _update_display() -> void:
    if not item_instance:
        tooltip_text = ""
        return

    item_name_label.modulate = item_instance.item.get_inventory_color()
    var display_name := item_instance.get_full_display_name() if item_instance.get_full_display_name() else item_instance.item.name

    # Handle display based on mode
    match display_mode:
        DisplayMode.INVENTORY:
            item_name_label.text = display_name
            price_label.visible = false
        DisplayMode.EQUIPPED:
            item_name_label.text = display_name
            price_label.visible = false
        DisplayMode.SHOP_BUY:
            if item_instance.count > 1:
                item_name_label.text = display_name
            else:
                item_name_label.text = display_name
            price_label.text = "%d gold" % item_instance.item.calculate_buy_value(item_instance.item_data)
            price_label.visible = true
        DisplayMode.SHOP_SELL:
            if item_instance.count > 1:
                item_name_label.text = display_name
            else:
                item_name_label.text = display_name
            var sell_value := item_instance.item.calculate_sell_value(item_instance.item_data)
            price_label.text = "%d gold" % sell_value
            price_label.visible = true

    # Set simple tooltip text to trigger custom tooltip system
    tooltip_text = display_name

    # Update background after display update
    _update_background()
    _update_condition_bar()  # Update condition bar when display changes

    # Ensure layout updates when content changes
    call_deferred("_ensure_layout_update")

func _update_action_button() -> void:
    if not item_instance:
        return

    match display_mode:
        DisplayMode.INVENTORY:
            _update_inventory_action_button()
        DisplayMode.EQUIPPED:
            _update_equipped_action_button()
        DisplayMode.SHOP_BUY:
            _update_shop_buy_button()
        DisplayMode.SHOP_SELL:
            _update_shop_sell_button()

func _update_inventory_action_button() -> void:
    # Items should remain usable during combat - combat disabled only affects weapons
    # Consumable items (potions, scrolls, etc.) can be used during combat
    action_button.disabled = false

    if item_instance.item is Equippable:
        # Weapons can always be equipped/unequipped
        # Set a fixed width to prevent layout changes
        action_button.custom_minimum_size.x = 80
        # Simple check: if this entry represents equipped weapon, show unequip
        if item_instance.is_equipped:
            action_button.text = "Unequip"
        else:
            action_button.text = "Equip"
    else:
        action_button.text = "Use"
    # Reset to default width for non-weapons
    action_button.custom_minimum_size.x = 80

func _update_equipped_action_button() -> void:
    # In equipped mode, always show "Unequip" button
    action_button.text = "Unequip"
    action_button.custom_minimum_size.x = 80
    action_button.disabled = false

func _update_shop_buy_button() -> void:
    action_button.text = "Buy"
    action_button.custom_minimum_size.x = 60
    # Check if player can afford this item
    action_button.disabled = GameState.player.gold < item_instance.item.calculate_buy_value(item_instance.item_data)

func _update_shop_sell_button() -> void:
    action_button.text = "Sell"
    action_button.custom_minimum_size.x = 60
    # Check if shopkeeper can afford this item
    var sell_value := item_instance.item.calculate_sell_value(item_instance.item_data)
    action_button.disabled = shopkeeper_gold < sell_value

func _update_background() -> void:
    # Create a StyleBoxFlat for custom background colors
    var style_box := StyleBoxFlat.new()

    # Check if this entry represents equipped item (but not in equipped display mode)
    var is_this_equipped := (display_mode != DisplayMode.EQUIPPED and
                             item_instance.item is Equippable and item_instance.is_equipped)

    if is_this_equipped:
        # Use a proper bright green
        style_box.bg_color = Color("#264125ff")  # Bright green
        background.add_theme_stylebox_override("panel", style_box)

    else:
        # Default state - remove override to use theme default
        background.remove_theme_stylebox_override("panel")


func _update_condition_bar() -> void:
    # Show condition bar for equippable items with damage (in any display mode)
    var should_show: bool = (item_instance.item is Equippable and
                      item_instance.item_data and
                      item_instance.item_data.current_condition < (item_instance.item as Equippable).get_max_condition())

    if should_show:
        # Update the progress bar value
        var max_condition := (item_instance.item as Equippable).get_max_condition()
        var current_condition := item_instance.item_data.current_condition
        condition_bar.max_value = max_condition
        condition_bar.value = current_condition
        condition_bar.visible = true

        # Update color based on condition level
        var condition_ratio := float(current_condition) / float(max_condition)
        var style_fill := StyleBoxFlat.new()
        style_fill.set_corner_radius_all(2)

        if condition_ratio > 0.7:
            style_fill.bg_color = Color(0.2, 0.8, 0.2)  # Green for good condition
        elif condition_ratio > 0.3:
            style_fill.bg_color = Color(0.8, 0.8, 0.2)  # Yellow for moderate damage
        else:
            style_fill.bg_color = Color(0.8, 0.2, 0.2)  # Red for heavy damage

        condition_bar.add_theme_stylebox_override("fill", style_fill)
    else:
        # Hide condition bar for undamaged weapons or non-weapons
        condition_bar.visible = false

func _on_background_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
        item_selected.emit(item_instance)

func _on_action_button_pressed() -> void:
    if not item_instance.item:
        return

    match display_mode:
        DisplayMode.INVENTORY:
            item_used.emit(item_instance)
        DisplayMode.EQUIPPED:
            item_used.emit(item_instance)
        DisplayMode.SHOP_BUY:
            item_bought.emit(item_instance)
        DisplayMode.SHOP_SELL:
            item_sold.emit(item_instance)

## Override to provide custom tooltip
func _make_custom_tooltip(_for_text: String) -> Control:
    if not item_instance:
        return null

    var tooltip := custom_tooltip_scene.instantiate() as CustomItemTooltip
    tooltip.setup_tooltip(item_instance.item, item_instance.count, item_instance.item_data)
    return tooltip

## Force layout update when content changes
func _ensure_layout_update() -> void:
    # Force layout updates on containers to ensure proper sizing
    # Since we are now a MarginContainer, update ourselves
    update_minimum_size()
