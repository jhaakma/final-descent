class_name InventoryRow extends MarginContainer

## Reusable component for displaying items with action buttons
##
## This component can be used in different contexts (inventory, shop, etc.)
## and adapts its display and functionality based on the display mode.

signal item_selected(item: Item)
signal item_used(item: Item, item_data)
signal item_bought(item: Item)
signal item_sold(item: Item, item_data)

enum DisplayMode {
    INVENTORY,   # Show Use/Equip buttons
    SHOP_BUY,    # Show Buy button with price
    SHOP_SELL    # Show Sell button with price
}

# Preload the custom tooltip scene
const CUSTOM_TOOLTIP_SCENE = preload("res://uielements/CustomItemTooltip.tscn")

@onready var background: Panel = %Background
@onready var item_name_label: Label = %ItemName
@onready var price_label: Label = %PriceLabel
@onready var action_button: Button = %ActionButton
@onready var condition_bar: ProgressBar = %ConditionBar  # Reference to scene element

var item_resource: Item
var count: int
var is_selected: bool = false
var is_combat_disabled: bool = false
var custom_display_name: String = ""
var item_data = null  # ItemData instance for this specific item
var is_equipped: bool = false  # Simple flag to indicate if this entry represents equipped item
var display_mode: DisplayMode = DisplayMode.INVENTORY
var shopkeeper_gold: int = 0  # For shop contexts, to determine if items can be afforded

func _ready() -> void:
    # Connect the background click for selection
    background.gui_input.connect(_on_background_input)
    action_button.pressed.connect(_on_action_button_pressed)

    _update_display()
    _update_action_button()

## Setup the row with item data (inventory mode)
func setup(_item_resource: Item, _count: int, _is_combat_disabled: bool = false) -> void:
    setup_with_mode(_item_resource, _count, DisplayMode.INVENTORY, _is_combat_disabled, "", null, false, 0)

## Setup the row with custom display name and item data (inventory mode)
func setup_with_custom_name(_item_resource: Item, _count: int, _is_combat_disabled: bool, _custom_name: String, _item_data = null, _is_equipped: bool = false) -> void:
    setup_with_mode(_item_resource, _count, DisplayMode.INVENTORY, _is_combat_disabled, _custom_name, _item_data, _is_equipped, 0)

## Setup the row for shop context
func setup_for_shop(_item_resource: Item, _count: int, _display_mode: DisplayMode, _custom_name: String = "", _item_data = null, _shopkeeper_gold: int = 0) -> void:
    setup_with_mode(_item_resource, _count, _display_mode, false, _custom_name, _item_data, false, _shopkeeper_gold)

## Internal setup method with all parameters
func setup_with_mode(_item_resource: Item, _count: int, _display_mode: DisplayMode, _is_combat_disabled: bool = false, _custom_name: String = "", _item_data = null, _is_equipped: bool = false, _shopkeeper_gold: int = 0) -> void:
    item_resource = _item_resource
    count = _count
    display_mode = _display_mode
    is_combat_disabled = _is_combat_disabled
    custom_display_name = _custom_name
    item_data = _item_data
    is_equipped = _is_equipped
    shopkeeper_gold = _shopkeeper_gold

    print("Setting up row for: ", custom_display_name if custom_display_name else (item_resource.name if item_resource else "none"), " mode: ", DisplayMode.keys()[display_mode])

    if is_node_ready():
        _update_display()
        _update_action_button()
        _update_background()
        _update_condition_bar()

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

    var display_name = custom_display_name if custom_display_name else item_resource.name

    # Handle display based on mode
    match display_mode:
        DisplayMode.INVENTORY:
            item_name_label.text = display_name + " x%d" % count
            price_label.visible = false
        DisplayMode.SHOP_BUY:
            if count > 1:
                item_name_label.text = display_name + " (x%d)" % count
            else:
                item_name_label.text = display_name
            price_label.text = "%d gold" % item_resource.purchase_value
            price_label.visible = true
        DisplayMode.SHOP_SELL:
            if count > 1:
                item_name_label.text = display_name + " (x%d)" % count
            else:
                item_name_label.text = display_name
            var sell_value = Item.calculate_sell_value(item_resource, item_data)
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
    if not item_resource:
        return

    match display_mode:
        DisplayMode.INVENTORY:
            _update_inventory_action_button()
        DisplayMode.SHOP_BUY:
            _update_shop_buy_button()
        DisplayMode.SHOP_SELL:
            _update_shop_sell_button()

func _update_inventory_action_button() -> void:
    action_button.disabled = is_combat_disabled

    if item_resource is ItemWeapon:
        # Weapons can always be equipped/unequipped
        action_button.disabled = false
        # Set a fixed width to prevent layout changes
        action_button.custom_minimum_size.x = 80
        # Simple check: if this entry represents equipped weapon, show unequip
        if is_equipped:
            action_button.text = "Unequip"
        else:
            action_button.text = "Equip"
    else:
        action_button.text = "Use"
        # Reset to default width for non-weapons
        action_button.custom_minimum_size.x = 0

func _update_shop_buy_button() -> void:
    action_button.text = "Buy"
    action_button.custom_minimum_size.x = 60
    # Check if player can afford this item
    action_button.disabled = GameState.player.gold < item_resource.purchase_value

func _update_shop_sell_button() -> void:
    action_button.text = "Sell"
    action_button.custom_minimum_size.x = 60
    # Check if shopkeeper can afford this item
    var sell_value = Item.calculate_sell_value(item_resource, item_data)
    action_button.disabled = shopkeeper_gold < sell_value

func _update_background() -> void:
    # Create a StyleBoxFlat for custom background colors
    var style_box = StyleBoxFlat.new()

    # Check if this entry represents equipped item
    var is_this_equipped = (item_resource is ItemWeapon and is_equipped)

    if is_this_equipped:
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

func _update_condition_bar() -> void:
    # Show condition bar for weapons with damage (in any display mode)
    var should_show = (item_resource is ItemWeapon and
                      item_data and
                      item_data.current_condition < item_resource.condition)

    if should_show:
        # Update the progress bar value
        var max_condition = item_resource.condition
        var current_condition = item_data.current_condition
        condition_bar.max_value = max_condition
        condition_bar.value = current_condition
        condition_bar.visible = true

        # Update color based on condition level
        var condition_ratio = float(current_condition) / float(max_condition)
        var style_fill = StyleBoxFlat.new()
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
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        item_selected.emit(item_resource)

func _on_action_button_pressed() -> void:
    if not item_resource:
        return

    match display_mode:
        DisplayMode.INVENTORY:
            item_used.emit(item_resource, item_data)
        DisplayMode.SHOP_BUY:
            item_bought.emit(item_resource)
        DisplayMode.SHOP_SELL:
            item_sold.emit(item_resource, item_data)

## Override to provide custom tooltip
func _make_custom_tooltip(_for_text: String) -> Control:
    if not item_resource:
        return null

    var tooltip = CUSTOM_TOOLTIP_SCENE.instantiate()
    tooltip.setup_tooltip(item_resource, count, item_data)
    return tooltip

## Force layout update when content changes
func _ensure_layout_update() -> void:
    # Force layout updates on containers to ensure proper sizing
    # Since we are now a MarginContainer, update ourselves
    update_minimum_size()
