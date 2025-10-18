class_name RepairTool extends Item

@export var repair_amount: int = 5  # Amount to repair item condition

func get_category() -> Item.ItemCategory:
    return Item.ItemCategory.MISC

func _on_use(_item_data: ItemData) -> bool:
    var player := GameState.player

    # Get all equipped items that can be repaired
    var available_items: Array[ItemInstance] = []
    var all_equipped := player.get_all_equipped_items()

    for item_instance: ItemInstance in all_equipped:
        if item_instance.item_data and item_instance.item is Equippable:
            var equippable := item_instance.item as Equippable
            var current_condition := item_instance.item_data.current_condition
            var max_condition := equippable.get_max_condition()
            if current_condition < max_condition:
                available_items.append(item_instance)

    # Check if we have any items to repair
    if available_items.is_empty():
        LogManager.log_warning("No damaged equipped items to repair.")
        return false

    # Show selection popup
    GameState.ui_manager.show_repair_selection_popup(available_items, _on_item_selected_for_repair)
    return true

func _on_item_selected_for_repair(selected_item: ItemInstance) -> void:
    if selected_item.item_data and selected_item.item is Equippable:
        var equippable := selected_item.item as Equippable
        var current_condition := selected_item.item_data.current_condition
        var max_condition := equippable.get_max_condition()

        var actual_repair := mini(repair_amount, max_condition - current_condition)
        selected_item.item_data.current_condition += actual_repair
        selected_item.item_data_updated()

        # Emit inventory_changed signal to update UI
        GameState.player.emit_signal("inventory_changed")

        LogManager.log_success("Repaired %s by %d points" % [selected_item.item.name, actual_repair])

func get_description() -> String:
    return "Repairs %d condition to a selected equipped item." % [repair_amount]

func get_inventory_color() -> Color:
    return Color("#747065ff")