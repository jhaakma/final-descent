class_name Item extends Resource

@export var name: String = "Item"
@export var description: String = ""
@export var purchase_value: int = 10

# Returns true if the item was consumed on use
func _on_use() -> bool:
    # Define item use behavior here
    return false

func use() -> void:
    var did_consume := _on_use()
    if did_consume:
        GameState.remove_item(self)

func on_pickup() -> void:
    LogManager.log_message("Received item: %s" % name)

# Calculate sell value considering item condition
static func calculate_sell_value(item: Item, item_data: ItemData = null) -> int:
    var base_sell_value := item.purchase_value / 2

    # If item has condition data and is damaged, reduce sell value
    if item_data and item_data.current_condition < get_max_condition_for_item(item):
        var max_condition := get_max_condition_for_item(item)
        var condition_ratio := float(item_data.current_condition) / float(max_condition)
        # Apply condition modifier: full condition = 100%, broken = 10% of base value
        var condition_modifier: float = lerp(0.1, 1.0, condition_ratio)
        return int(base_sell_value * condition_modifier)

    return base_sell_value

# Get maximum condition for an item type
static func get_max_condition_for_item(item: Item) -> int:
    if item is ItemWeapon:
        var weapon := item as ItemWeapon
        return weapon.condition
    # Other item types could have condition in the future
    return 20  # Default max condition

func get_description() -> String:
    return description
