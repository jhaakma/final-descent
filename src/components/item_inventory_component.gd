# components/inventory_component.gd
class_name ItemInventoryComponent extends RefCounted

# Manages an inventory using ItemStacks
signal inventory_changed
signal item_added(item: Item, amount: int)
signal item_removed(item: Item, amount: int)

var item_stacks: Dictionary[Item, ItemStack] = {}  # Item -> ItemStack mapping
var max_slots: int = -1  # -1 means unlimited slots

func _init(max_inventory_slots: int = -1) -> void:
    max_slots = max_inventory_slots

# === BASIC INVENTORY OPERATIONS ===

# Add items to the inventory
func add_item(item: Item, amount: int = 1) -> bool:
    if amount <= 0:
        return false

    # Check slot limit
    if max_slots > 0 and item not in item_stacks and get_used_slots() >= max_slots:
        return false

    # Get or create stack
    var stack: ItemStack
    if item in item_stacks:
        stack = item_stacks[item]
    else:
        stack = ItemStack.new(item, 0)
        item_stacks[item] = stack
        stack.stack_changed.connect(_on_stack_changed)

    # Add to stack
    stack.add_stack_count(amount)

    item_added.emit(item, amount)
    inventory_changed.emit()
    return true

# Add an item with specific instance data
func add_item_instance(item: Item, item_data: ItemData = null) -> bool:
    # Check slot limit
    if max_slots > 0 and item not in item_stacks and get_used_slots() >= max_slots:
        return false

    # Get or create stack
    var stack: ItemStack
    if item in item_stacks:
        stack = item_stacks[item]
    else:
        stack = ItemStack.new(item, 0)
        item_stacks[item] = stack
        stack.stack_changed.connect(_on_stack_changed)

    # Create ItemData if none provided
    if item_data == null:
        item_data = preload("res://src/components/item_data.gd").new()

    # Add instance
    stack.add_instance(item_data)

    item_added.emit(item, 1)
    inventory_changed.emit()
    return true

# Add an item instance back without changing total count (for returning equipped items)
func add_item_instance_no_count_change(item: Item, item_data: ItemData) -> bool:
    # Get existing stack (must exist since weapon was taken from it)
    if item not in item_stacks:
        return false

    var stack: ItemStack = item_stacks[item]
    stack.add_instance_no_count_change(item_data)

    inventory_changed.emit()
    return true

# Remove items from inventory (generic removal)
func remove_item(item: Item, amount: int = 1) -> int:
    if amount <= 0 or item not in item_stacks:
        return 0

    var stack: ItemStack = item_stacks[item]
    var total_available: int = stack.get_total_count()
    var to_remove: int = min(amount, total_available)

    if to_remove == 0:
        return 0

    # Remove items from stack
    stack.remove_any(to_remove)

    # Remove empty stacks
    if stack.is_empty():
        stack.stack_changed.disconnect(_on_stack_changed)
        item_stacks.erase(item)

    item_removed.emit(item, to_remove)
    inventory_changed.emit()
    return to_remove

# Remove a specific item instance with ItemData
func remove_item_instance(item: Item, item_data: ItemData) -> bool:
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
    return item_stacks[item].get_total_count() >= amount

# Get the total count of an item
func get_item_count(item: Item) -> int:
    if item not in item_stacks:
        return 0
    return item_stacks[item].get_total_count()

# Get the stack for a specific item
func get_item_stack(item: Item) -> ItemStack:
    return item_stacks.get(item)

# Get all items in inventory
func get_all_items() -> Array[Item]:
    var items: Array[Item] = []
    for item: Item in item_stacks.keys():
        items.append(item)
    return items

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
func get_item_tiles() -> Array[ItemTile]:
    var tiles: Array[ItemTile] = []

    for item: Item in item_stacks.keys():
        var stack: ItemStack = item_stacks[item]
        var stack_info := stack.get_display_info()

        # Add generic items if available
        if stack_info.generic_count > 0:
            var tile := ItemTile.new(
                item,
                null,  # no item_data for generic items
                stack_info.generic_count,
                item.name,
                "",  # no description suffix for generic items
                false  # not equipped (equipped items are separate)
            )
            tiles.append(tile)

        # Add each unique instance as a separate tile
        for instance_info: Dictionary in stack_info.unique_instances:
            var instance_data: ItemData = instance_info.item_data
            var description: String = instance_info.description

            var tile := ItemTile.new(
                item,
                instance_data,
                1,  # unique instances are always count 1
                item.name,
                description,
                false  # not equipped (equipped items are separate)
            )
            tiles.append(tile)

    return tiles

# Merge items from another inventory
func merge_from(other_inventory: ItemInventoryComponent) -> Array[Item]:
    var failed_items: Array[Item] = []

    for item in other_inventory.get_all_items():
        var other_stack := other_inventory.get_item_stack(item)
        var stack_info := other_stack.get_display_info()

        # Try to add stack count
        if stack_info.stack_count > 0:
            if not add_item(item, stack_info.stack_count):
                failed_items.append(item)

        # Try to add each unique instance
        for instance_info: Variant in stack_info.unique_instances:
            if not add_item_instance(item, instance_info.item_data):
                failed_items.append(item)

    return failed_items

# Get total value of all items in inventory
func get_total_value() -> int:
    var total: int = 0
    for item: Item in item_stacks.keys():
        var count := get_item_count(item)
        total += item.purchase_value * count
    return total



# === PRIVATE METHODS ===

func _on_stack_changed() -> void:
    inventory_changed.emit()
