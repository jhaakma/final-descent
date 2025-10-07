class_name ShopItemRow extends VBoxContainer

signal buy_item(item: Item)
signal sell_item(item: Item, item_data)

@onready var item_name_label: Label = %ItemName
@onready var item_desc_label: Label = %ItemDescription
@onready var item_price_label: Label = %Price
@onready var buy_button: Button = %BuySellButton

var item_resource: Item
var item_data = null  # ItemData for the item instance
var is_buying: bool
var count: int
var is_disabled: bool
var custom_display_name: String = ""
var setup_pending: bool = false

func _ready() -> void:
    # If setup was called before _ready, update UI now
    if setup_pending:
        _update_ui()

func setup(_item_resource: Item, _count: int, _is_buying: bool, _is_disabled: bool, _item_data = null, _custom_display_name: String = "") -> void:
    item_resource = _item_resource
    count = _count
    is_buying = _is_buying
    is_disabled = _is_disabled
    item_data = _item_data
    custom_display_name = _custom_display_name
    setup_pending = true

    # If the node is already ready, update UI immediately
    if is_node_ready():
        _update_ui()

func _update_ui() -> void:
    if item_resource == null:
        return

    setup_pending = false
    print("Setting up shop item row for item: %s" % item_resource.name)

    # Use custom display name if provided, otherwise use default format
    if custom_display_name != "":
        item_name_label.text = custom_display_name
    else:
        item_name_label.text = item_resource.name + " (x%d)" % count

    item_desc_label.text = item_resource.get_description()

    if is_buying:
        item_price_label.text = "%d gold" % item_resource.purchase_value
        buy_button.text = "Buy"
        buy_button.disabled = GameState.player.gold < item_resource.purchase_value
        buy_button.pressed.connect(_on_buy_item.bind(item_resource))
    else:
        var sell_value = Item.calculate_sell_value(item_resource, item_data)
        item_price_label.text = "%d gold" % sell_value
        buy_button.text = "Sell"
        buy_button.disabled = is_disabled
        buy_button.pressed.connect(_on_sell_item.bind(item_resource, item_data))



func _on_buy_item(item: Item) -> void:
    buy_item.emit(item)

func _on_sell_item(item: Item, data) -> void:
    sell_item.emit(item, data)
