# components/item_instance.gd
class_name ItemInstance extends RefCounted

## Represents a single displayable inventory entry
##
## An ItemInstance represents either:
## - A stack of generic items (item_data is null, count > 1 possible)
## - A single unique item instance (item_data is present, count is always 1)
##
## This provides a consistent interface for UI systems to display and interact
## with inventory items regardless of whether they're generic or unique instances.

var item: Item
var item_data: ItemData  # null for generic items, present for unique instances
var count: int  # quantity for generic items, always 1 for unique instances
var is_equipped: bool = false  # Whether this item is currently equipped (for weapons)
func _init(
    p_item: Item,
    p_item_data: ItemData = null,
    p_count: int = 1,

) -> void:
    item = p_item
    item_data = p_item_data
    count = p_count


## Check if this tile represents a generic stack (no specific ItemData)
func is_generic_stack() -> bool:
    return item_data == null

## Check if this tile represents a unique instance with ItemData
func is_unique_instance() -> bool:
    return item_data != null

## Get the display name with quantity if applicable
func get_display_name_with_count() -> String:
    if count > 1:
        return "%s (%d)" % [item.name, count]
    else:
        return item.name

## Get the full display name including description suffix
func get_full_display_name() -> String:
    var full_name := item.name
    if count > 1:
        full_name += " (%d)" % count
    elif is_unique_instance():
        full_name += " (1)"

    return full_name

## Get sort key for consistent ordering
func get_sort_key() -> String:
    var base_key := item.name
    if is_equipped:
        base_key = "0_" + base_key  # Equipped items first
    elif is_unique_instance():
        base_key += "_instance"
    else:
        base_key += "_generic"

    return base_key

## Check if player still has this item/instance available
func is_available_in_inventory() -> bool:
    if is_unique_instance():
        # Check if this specific instance is still available
        var item_stack: ItemStack = GameState.player.inventory.get_item_stack(item)
        return item_stack != null and item_data in item_stack.get_all_instances()
    else:
        # Check if we have generic items available
        return GameState.player.has_item(item)

## Use this item tile (handles both generic and specific instances)
func use_item() -> bool:
    if not is_available_in_inventory():
        return false

    if item is ItemWeapon:
        var equipped_weapon: = GameState.player.get_equipped_weapon()
        # Special handling for weapons
        var is_already_equipped: bool = (
            equipped_weapon != null and
            equipped_weapon.item == item and
            equipped_weapon.item_data == item_data
        )

        if is_already_equipped:
            GameState.player.unequip_weapon()
        else:
            GameState.player.equip_weapon(self)
        return true
    else:
        # For consumables and other items
        if is_unique_instance():
            # Remove the specific instance and use the item
            if GameState.player.inventory.remove_item_instance(self):
                item.use(item_data)
                return true
            return false
        else:
            # Use generic item (this will automatically handle removal)
            item.use(item_data)
            return true

func matches(other: ItemInstance) -> bool:
    return item == other.item and item_data == other.item_data

## If item data was modified to be back to generic state, remove from instance
func item_data_updated() -> bool:
    if is_unique_instance() and not item_data.is_unique():
        item_data = null
        return true
    return false