# components/item_data.gd
class_name ItemData extends RefCounted

# Base class for storing instance-specific data for items
# This allows items to have unique properties while being stacked

# Common instance data that many items might have
var _initial_condition: int = -1
var current_condition: int = -1  # Current condition (item-specific, like weapon durability)

func _init(initial_condition: int = -1) -> void:
    _initial_condition = initial_condition
    current_condition = _initial_condition

# Check if this item data represents a unique instance that shouldn't stack
func is_unique() -> bool:
    return (
        current_condition < _initial_condition
    )



# Apply damage to this item's condition
func damage_condition(amount: int) -> void:
    current_condition = max(0, current_condition - amount)

# Repair this item's condition
func repair_condition(amount: int) -> void:
    current_condition = min(20, current_condition + amount)  # Assuming 20 is max condition


# Check if this ItemData should be removed because it has no unique data
func is_empty() -> bool:
    # If condition is at its initial value and no other unique data exists
    return current_condition == _initial_condition

# Check if two ItemData instances are equivalent (can be stacked together)
func can_stack_with(other: ItemData) -> bool:
    if is_unique() or other.is_unique():
        return false
    return (
        current_condition == other.current_condition
    )