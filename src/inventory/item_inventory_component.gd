# components/inventory_component.gd
class_name ItemInventoryComponent extends RefCounted

# Manages an inventory using ItemStacks
signal inventory_changed
signal item_added(item_instance: ItemInstance)
signal item_removed(item_instance: ItemInstance)

var item_stacks: Dictionary[Item, ItemStack] = {}  # Item -> ItemStack mapping
var max_slots: int = -1  # -1 means unlimited slots

func _init(max_inventory_slots: int = -1) -> void:
    max_slots = max_inventory_slots

# === BASIC INVENTORY OPERATIONS ===

# Add items to the inventory
func add_item(item_instance: ItemInstance) -> bool:
    if item_instance.count<= 0:
        return false

    # Check slot limit
    if max_slots > 0 and item_instance.item not in item_stacks and get_used_slots() >= max_slots:
        return false

    # Get or create stack
    var stack: ItemStack
    if item_instance.item in item_stacks:
        stack = item_stacks[item_instance.item]
    else:
        stack = ItemStack.new(item_instance.item, 0)
        item_stacks[item_instance.item] = stack
        stack.stack_changed.connect(_on_stack_changed)

    # Add to stack
    if item_instance.item_data != null:
        stack.add_instance(item_instance.item_data)
    else:
        stack.add_stack_count(item_instance.count)


    item_added.emit(item_instance)
    inventory_changed.emit()
    return true

# Add an item with specific instance data
func add_item_instance(item_instance: ItemInstance) -> bool:
    # Check slot limit
    if max_slots > 0 and item_instance.item not in item_stacks and get_used_slots() >= max_slots:
        return false

    # Get or create stack
    var stack: ItemStack
    if item_instance.item in item_stacks:
        stack = item_stacks[item_instance.item]
    else:
        stack = ItemStack.new(item_instance.item, 0)
        item_stacks[item_instance.item] = stack
        stack.stack_changed.connect(_on_stack_changed)

    # Create ItemData if none provided
    if item_instance.item_data == null:
        item_instance.item_data = ItemData.new()

    # Add instance
    stack.add_instance(item_instance.item_data)

    item_added.emit(item_instance)
    inventory_changed.emit()
    return true


# Remove items from inventory
func remove_item(item_instance: ItemInstance) -> bool:
    return remove_item_instance(item_instance)

# Remove a specific item instance with ItemData
func remove_item_instance(item_instance: ItemInstance) -> bool:
    if item_instance.item not in item_stacks:
        return false

    var stack: ItemStack = item_stacks[item_instance.item]
    var success := stack.remove_instance_by_reference(item_instance.item_data)

    if success:
        # Remove empty stacks
        if stack.is_empty():
            stack.stack_changed.disconnect(_on_stack_changed)
            item_stacks.erase(item_instance.item)

        item_removed.emit(item_instance.item, 1)
        inventory_changed.emit()

    return success

# Take items from inventory and return their ItemData
func take_items(item: Item, amount: int = 1) -> Array:
    if amount <= 0 or item not in item_stacks:
        return []

    var stack: ItemStack = item_stacks[item]
    var taken_items := stack.remove_any(amount)

    # Remove empty stacks
    if stack.is_empty():
        stack.stack_changed.disconnect(_on_stack_changed)
        item_stacks.erase(item)

    if taken_items.size() > 0:
        item_removed.emit(item, taken_items.size())
        inventory_changed.emit()

    return taken_items

# Take a specific item instance by its ItemData
func take_item_instance(item: Item, item_data: ItemData) -> bool:
    if item not in item_stacks:
        return false

    var stack: ItemStack = item_stacks[item]
    var success := stack.remove_instance_by_reference(item_data)

    if success:
        # Remove empty stacks
        if stack.is_empty():
            stack.stack_changed.disconnect(_on_stack_changed)
            item_stacks.erase(item)

        item_removed.emit(item, 1)
        inventory_changed.emit()

    return success

# === INVENTORY QUERIES ===

# Check if inventory has enough of an item
func has_item(item: Item, amount: int = 1) -> bool:
    if item not in item_stacks:
        return false
    var count := item_stacks[item].get_total_count()
    return count >= amount

# Get the total count of an item
func get_item_count(item: Item) -> int:
    if item not in item_stacks:
        return 0
    return item_stacks[item].get_total_count()

# Get the stack for a specific item
func get_item_stack(item: Item) -> ItemStack:
    return item_stacks.get(item)


# Get all item stacks
func get_all_stacks() -> Array[ItemStack]:
    var stacks: Array[ItemStack] = []
    for stack: ItemStack in item_stacks.values():
        stacks.append(stack)
    return stacks

# Get number of used inventory slots
func get_used_slots() -> int:
    return item_stacks.size()

# Get maximum slots (-1 for unlimited)
func get_max_slots() -> int:
    return max_slots

# Check if inventory is full
func is_full() -> bool:
    if max_slots < 0:
        return false
    return get_used_slots() >= max_slots

# Check if inventory is empty
func is_empty() -> bool:
    return item_stacks.is_empty()

# === UTILITY METHODS ===

# Clear all items from inventory
func clear() -> void:
    for stack: ItemStack in item_stacks.values():
        stack.stack_changed.disconnect(_on_stack_changed)
    item_stacks.clear()
    inventory_changed.emit()

# Get detailed inventory information for UI display
func get_inventory_display_info() -> Array:
    var display_info: Array = []

    for item: Item in item_stacks.keys():
        var stack: ItemStack = item_stacks[item]
        var stack_info := stack.get_display_info()
        display_info.append(stack_info)

    return display_info

# Generate ItemTiles for consistent UI display across all systems
func get_item_tiles() -> Array[ItemInstance]:
    var tiles: Array[ItemInstance] = []

    for stack: ItemStack in item_stacks.values():
        tiles.append_array(stack.get_item_tiles())

    return tiles


# === PRIVATE METHODS ===

func _on_stack_changed() -> void:
    inventory_changed.emit()
