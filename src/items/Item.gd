class_name Item extends Resource

@export var name: String = "Item"
@export var purchase_value: int = 10


func get_description() -> String:
    return ""

## Returns true if the item was consumed on use
func _on_use(_item_data: ItemData) -> bool:
    return true

## Check if the item gets consumed on use
func get_consumable() -> bool:
    return true


# Calculate sell value considering item condition
func calculate_sell_value( _item_data: ItemData = null) -> int:
    return purchase_value / 2

## Do not override this method; use _on_use instead
func use(item_data: ItemData) -> void:
    var success: bool = _on_use(item_data)
    if success and get_consumable():
        GameState.player.remove_item(ItemInstance.new(self, item_data, 1))
