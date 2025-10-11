class_name ShopItemRow extends VBoxContainer

# signal buy_item(item: Item)
# signal sell_item(item: Item, item_data: ItemData)

@onready var item_name_label: Label = %ItemName
@onready var item_desc_label: Label = %ItemDescription
@onready var item_price_label: Label = %Price
@onready var buy_button: Button = %BuySellButton

var item_instance: ItemInstance = null
var is_buying: bool
var count: int
var is_disabled: bool
var custom_display_name: String = ""
var setup_pending: bool = false

func setup(_item_tile: ItemInstance, _count: int, _is_buying: bool, _is_disabled: bool, _custom_display_name: String = "") -> void:
    item_instance = _item_tile
    count = _count
    is_buying = _is_buying
    is_disabled = _is_disabled
    custom_display_name = _custom_display_name
    setup_pending = true
