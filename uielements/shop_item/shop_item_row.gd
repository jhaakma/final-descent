class_name ShopItemRow extends VBoxContainer

signal buy_item(item: Item)
signal sell_item(item: Item)

@onready var item_name_label: Label = %ItemName
@onready var item_desc_label: Label = %ItemDescription
@onready var item_price_label: Label = %Price
@onready var buy_button: Button = %BuySellButton

var item_resource: Item
var is_buying: bool
var count: int
var is_disabled: bool

func _ready() -> void:
    print("Setting up shop item row for item: %s" % item_resource.name)
    item_name_label.text = item_resource.name + " (x%d)" % count
    item_desc_label.text = item_resource.get_description()
    if is_buying:
        item_price_label.text = "%d gold" % item_resource.purchase_value
        buy_button.text = "Buy"
        buy_button.disabled = GameState.player.gold < item_resource.purchase_value
        buy_button.pressed.connect(_on_buy_item.bind(item_resource))
    else:
        var sell_value = item_resource.get_sell_value()
        item_price_label.text = "%d gold" % sell_value
        buy_button.text = "Sell"
        buy_button.disabled = is_disabled
        buy_button.pressed.connect(_on_sell_item.bind(item_resource))

func setup(_item_resource: Item, _count: int, _is_buying: bool, _is_disabled: bool) -> void:
    item_resource = _item_resource
    count = _count
    is_buying = _is_buying
    is_disabled = _is_disabled



func _on_buy_item(item: Item) -> void:
    buy_item.emit(item)

func _on_sell_item(item: Item) -> void:
    sell_item.emit(item)
