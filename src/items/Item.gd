class_name Item extends Resource

enum ItemCategory {
    WEAPON,
    POTION,
    SCROLL,
    MISC
}

@export var name: String = "Item":
    get = _get_name
@export var purchase_value: int = 10

class AdditionalTooltipInfoData:
    var text: String
    var color: Color = Color(1, 1, 1)

func _get_name() -> String:
    return name

## Virtual method to be overridden by subclasses
func get_category() -> ItemCategory:
    return ItemCategory.MISC

func get_description() -> String:
    return ""

## Returns true if the item was consumed on use
func _on_use(_item_data: ItemData) -> bool:
    return true

## Check if the item gets consumed on use
func get_consumable() -> bool:
    return true

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    return []

# Calculate sell value considering item condition
func calculate_sell_value( _item_data: ItemData = null) -> int:
    return calculate_buy_value() / 2

func calculate_buy_value(_item_data: ItemData = null) -> int:
    return purchase_value

## Do not override this method; use _on_use instead
func use(item_data: ItemData) -> void:
    var success: bool = _on_use(item_data)
    if success and get_consumable():
        GameState.player.remove_item(ItemInstance.new(self, item_data, 1))

func get_inventory_color() -> Color:
    return Color(1, 1, 1)

## Get the category name as a string for UI display
func get_category_name() -> String:
    match get_category():
        ItemCategory.WEAPON:
            return "Weapons"
        ItemCategory.POTION:
            return "Potions"
        ItemCategory.MISC:
            return "Misc"
        _:
            return "Misc"
