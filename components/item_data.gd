# components/item_data.gd
class_name ItemData extends RefCounted

# Base class for storing instance-specific data for items
# This allows items to have unique properties while being stacked

# Common instance data that many items might have
var current_condition: int = 20  # Current condition (item-specific, like weapon durability)
var enchantments: Dictionary = {}  # String -> variant for enchantment data
var custom_name: String = ""  # Player-assigned custom name
var creation_time: float  # When this instance was created
var custom_properties: Dictionary = {}  # Flexible storage for any custom data

func _init(initial_condition: int = 20) -> void:
    current_condition = initial_condition
    creation_time = Time.get_unix_time_from_system()

# Check if this item data represents a unique instance that shouldn't stack
func is_unique() -> bool:
    return (
        current_condition < 20 or  # Item is damaged
        not enchantments.is_empty() or
        not custom_name.is_empty() or
        not custom_properties.is_empty()
    )

# Get a description of this item instance's unique properties
func get_instance_description() -> String:
    var parts: Array[String] = []

    if not custom_name.is_empty():
        parts.append("\"" + custom_name + "\"")

    # Condition is now shown visually with progress bar, so don't add text
    # if current_condition < 20:  # Commented out - using visual bar instead

    if not enchantments.is_empty():
        parts.append("Enchanted")

    return " ".join(parts)

# Apply damage to this item's condition
func damage_condition(amount: int) -> void:
    current_condition = max(0, current_condition - amount)

# Repair this item's condition
func repair_condition(amount: int) -> void:
    current_condition = min(20, current_condition + amount)  # Assuming 20 is max condition

# Add an enchantment to this item
func add_enchantment(enchantment_name: String, enchantment_data) -> void:
    enchantments[enchantment_name] = enchantment_data

# Remove an enchantment from this item
func remove_enchantment(enchantment_name: String) -> void:
    enchantments.erase(enchantment_name)

# Check if this item has a specific enchantment
func has_enchantment(enchantment_name: String) -> bool:
    return enchantment_name in enchantments

# Get enchantment data
func get_enchantment(enchantment_name: String):
    return enchantments.get(enchantment_name)

# Set a custom property
func set_custom_property(property_name: String, value) -> void:
    custom_properties[property_name] = value

# Get a custom property
func get_custom_property(property_name: String, default_value = null):
    return custom_properties.get(property_name, default_value)

# Create a copy of this ItemData
func duplicate() -> ItemData:
    var copy = ItemData.new(current_condition)
    copy.enchantments = enchantments.duplicate()
    copy.custom_name = custom_name
    copy.creation_time = creation_time
    copy.custom_properties = custom_properties.duplicate()
    return copy

# Check if two ItemData instances are equivalent (can be stacked together)
func can_stack_with(other: ItemData) -> bool:
    if is_unique() or other.is_unique():
        return false

    return (
        current_condition == other.current_condition and
        enchantments.hash() == other.enchantments.hash() and
        custom_name == other.custom_name and
        custom_properties.hash() == other.custom_properties.hash()
    )
