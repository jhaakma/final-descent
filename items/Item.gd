class_name Item extends Resource

@export var name: String = "Item"
@export var description: String = "An item."
@export var consumable: bool = true
@export var purchase_value: int = 10

func _on_use() -> void:
    # Define item use behavior here
    pass

func use() -> void:
    _on_use()
    if consumable:
        GameState.remove_item(self)

func on_pickup() -> void:
    LogManager.log_success("Found item: %s" % name)

func get_sell_value() -> int:
    return purchase_value / 2

func get_description() -> String:
    return description
