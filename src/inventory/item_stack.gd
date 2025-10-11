# components/item_stack.gd
class_name ItemStack extends RefCounted

# Represents a stack of items with a base count and specific instances
signal stack_changed

var item: Item  # The base item type
var stack_count: int = 0  # Number of generic instances
var item_instances: Array[ItemData] = []  # Specific instances with unique data

func _init(base_item: Item, initial_count: int = 0) -> void:
    item = base_item
    stack_count = max(0, initial_count)

# Get the total count of items in this stack (only inventory items)
func get_total_count() -> int:
    return stack_count

# Get the count of generic items (without specific ItemData)
func get_generic_count() -> int:
    return stack_count - item_instances.size()

# Get the count of unique instances with ItemData
func get_instance_count() -> int:
    return item_instances.size()

# Check if this stack is empty
func is_empty() -> bool:
    return stack_count == 0# Add generic items to the stack

func add_stack_count(amount: int) -> void:
    if amount > 0:
        stack_count += amount
        stack_changed.emit()

# Remove generic items from the stack
func remove_stack_count(amount: int) -> int:
    var removed: int = min(amount, stack_count)
    stack_count -= removed
    if removed > 0:
        # Check if we need to remove instances as well
        while stack_count < item_instances.size():
            item_instances.pop_back()
        stack_changed.emit()
    return removed

# Add a specific item instance
func add_instance(item_data: ItemData) -> void:
    # Try to merge with existing instances if possible
    if item_data != null:
        if not item_data.is_unique():
            for existing_data in item_instances:
                if item_data.can_stack_with(existing_data):
                    # Convert both instances to generic (remove from instances, don't change total count)
                    item_instances.erase(existing_data)
                    stack_changed.emit()
                    return
        # Add as a unique instance and increase total count
        item_instances.append(item_data)
    stack_count += 1
    stack_changed.emit()

# Add an instance back without changing total count (for returning equipped items)
func add_instance_no_count_change(item_data: ItemData) -> void:
    item_instances.append(item_data)
    stack_changed.emit()

# Convert a generic item to an instance without changing total count
func convert_generic_to_instance(item_data: ItemData) -> bool:
    var available := get_generic_count()
    if available > 0:
        item_instances.append(item_data)
        stack_changed.emit()
        return true
    return false

# Remove a specific item instance by reference
func remove_instance_by_reference(item_data: ItemData) -> bool:
    if item_data:
        var index := item_instances.find(item_data)
        if index >= 0:
            item_instances.remove_at(index)
            remove_stack_count(1)  # Decrease total count
            return true
    else:
        remove_stack_count(1)  # Remove a generic item if no specific instance provided
        return true
    return false

func remove(item_data: ItemData) -> bool:
    if item_data:
        return remove_instance_by_reference(item_data)
    else:
        # No specific instance provided, remove a generic item if available
        return remove_stack_count(1) > 0

# Get a specific item instance by index
func get_instance(index: int) -> ItemData:
    if index >= 0 and index < item_instances.size():
        return item_instances[index]
    return null

# Get all item instances
func get_all_instances() -> Array:
    return item_instances.duplicate()

# Remove any number of items from the stack (preferring generic items first)
func remove_any(amount: int) -> Array:
    var removed_instances: Array = []
    var remaining_to_remove: int = min(amount, stack_count)

    # Calculate how many are generic (total - instances)
    var generic_count := stack_count - item_instances.size()

    # First remove from generic items
    var removed_generic: int= min(remaining_to_remove, generic_count)
    if removed_generic > 0:
        stack_count -= removed_generic
        remaining_to_remove -= removed_generic

    # Then remove specific instances if needed
    while remaining_to_remove > 0 and item_instances.size() > 0:
        var removed_data : ItemData = item_instances.pop_back()
        removed_instances.append(removed_data)
        stack_count -= 1  # Decrease total count
        remaining_to_remove -= 1

    if removed_generic > 0 or removed_instances.size() > 0:
        stack_changed.emit()

    return removed_instances

# Take a single item (preferring generic items first)
func take_one() -> ItemInstance:
    if stack_count <= 0:
        return null

    # Calculate how many are generic (total - instances)
    var generic_count := stack_count - item_instances.size()

    if generic_count > 0:
        # Take from generic items
        stack_count -= 1
        stack_changed.emit()
        # Return a new default ItemData for generic items
        return ItemInstance.new(item, null, 1)
    elif item_instances.size() > 0:
        # Take from instances
        var taken: ItemData = item_instances.pop_back()
        stack_count -= 1
        stack_changed.emit()
        return ItemInstance.new(item, taken, 1)

    return null

# Check if this stack contains the same item type
func contains_item(check_item: Item) -> bool:
    return item == check_item

# Get the display name for this stack
func get_display_name() -> String:
    if item:
        return item.name
    return "Unknown Item"

# Get the description for this stack
func get_description() -> String:
    if item:
        return item.get_description()
    return "No description available"

# Get stack information for UI display
func get_display_info() -> Dictionary:
    var info := {
        "item": item,
        "total_count": get_total_count(),
        "generic_count": get_generic_count(),
        "instance_count": get_instance_count(),
        "unique_instances": [],
        "has_unique_instances": item_instances.size() > 0
    }

    # Add information about unique instances
    for i in range(item_instances.size()):
        var instance_data := item_instances[i]
        (info.unique_instances as Array).append({
            "index": i,
            "item_data": instance_data,
            "description": instance_data.get_instance_description(),
            "is_unique": instance_data.is_unique()
        })

    return info

# Split this stack into multiple stacks if needed
func split_stack(split_amount: int) -> ItemStack:
    if split_amount <= 0 or split_amount >= get_total_count():
        return null

    var new_stack := ItemStack.new(item, 0)

    # Split from generic count first
    var from_stack: int = min(split_amount, stack_count)
    if from_stack > 0:
        stack_count -= from_stack
        new_stack.stack_count = from_stack
        split_amount -= from_stack

    # Split instances if needed
    while split_amount > 0 and item_instances.size() > 0:
        var moved_instance: ItemData = item_instances.pop_back()
        new_stack.item_instances.append(moved_instance)
        split_amount -= 1

    stack_changed.emit()
    return new_stack

# Merge another ItemStack into this one (if same item type)
func merge_with(other_stack: ItemStack) -> bool:
    if not contains_item(other_stack.item):
        return false

    # Merge stack counts
    stack_count += other_stack.stack_count

    # Merge instances
    for instance in other_stack.item_instances:
        add_instance(instance)

    # Clear the other stack
    other_stack.stack_count = 0
    other_stack.item_instances.clear()

    stack_changed.emit()
    return true

func get_item_tiles() -> Array[ItemInstance]:
    var tiles: Array[ItemInstance] = []

    # Add generic items as ItemTiles
    if stack_count - item_instances.size() > 0:
        var generic_tile := ItemInstance.new(item, null, stack_count - item_instances.size())
        tiles.append(generic_tile)

    # Add each specific instance as an ItemInstance
    for instance_data in item_instances:
        var instance_tile := ItemInstance.new(item, instance_data, 1)
        tiles.append(instance_tile)

    return tiles