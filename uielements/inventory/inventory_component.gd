class_name InventoryComponent extends Node

## Component for handling inventory UI and interactions
##
## This component manages the inventory list, item selection, and item usage.
## It encapsulates all inventory-related functionality to promote single responsibility
## and componentization as per the project guidelines.
##
## Updated to work with the new ItemInventoryComponent system that supports
## ItemStacks with instance data for items like weapons with condition damage.

signal item_used
signal inventory_updated

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var inventory_list: VBoxContainer = %InventoryList

var selected_item: Item = null
var is_combat_disabled: bool = false
var inventory_rows: Array[InventoryRow] = []

# Preload the InventoryRow scene
const INVENTORY_ROW_SCENE = preload("res://uielements/inventory/InventoryRow.tscn")

func _ready() -> void:
    # Connect to GameState inventory changes
    GameState.player.inventory_changed.connect(_refresh_inventory)

    # Initialize inventory display
    _refresh_inventory()

## Call this to refresh the inventory display
func refresh() -> void:
    _refresh_inventory()

## Set whether inventory usage is disabled (e.g., during combat)
func set_combat_disabled(disabled: bool) -> void:
    is_combat_disabled = disabled
    # Update all existing rows
    for row in inventory_rows:
        row.set_combat_disabled(disabled)

## Get the currently selected item
func get_selected_item() -> Item:
    return selected_item

func _refresh_inventory() -> void:
    # Clear existing inventory rows
    for row in inventory_rows:
        row.queue_free()
    inventory_rows.clear()
    selected_item = null

    # Get detailed inventory information from the new system
    var inventory_display_info = GameState.player.get_inventory_display_info()
    var equipped_weapon = GameState.player.equipped_weapon
    var equipped_weapon_data = GameState.player.equipped_weapon_data

    # Collect all display entries (stacks + individual instances)
    var display_entries = []

    # Add equipped weapon as separate entry (it's not in inventory anymore)
    if equipped_weapon:
        var weapon_description = ""
        if equipped_weapon_data:
            weapon_description = equipped_weapon_data.get_instance_description()

        display_entries.append({
            "item": equipped_weapon,
            "count": 1,
            "is_stack": false,
            "is_equipped": true,
            "instance_data": equipped_weapon_data,
            "description_suffix": weapon_description
        })

    for stack_info in inventory_display_info:
        var item = stack_info.item

        # Add individual unique instances (no longer checking for equipped since it's separate)
        for instance_info in stack_info.unique_instances:
            display_entries.append({
                "item": item,
                "count": 1,
                "is_stack": false,
                "is_equipped": false,
                "instance_data": instance_info.item_data,
                "description_suffix": instance_info.description
            })

        # Add stack entry if there are available items
        if stack_info.generic_count > 0:
            display_entries.append({
                "item": item,
                "count": stack_info.generic_count,
                "is_stack": true,
                "is_equipped": false,
                "instance_data": null,
                "description_suffix": ""
            })    # Sort entries: equipped first, then by name
    display_entries.sort_custom(func(a, b):
        if a.is_equipped and not b.is_equipped:
            return true
        if b.is_equipped and not a.is_equipped:
            return false
        return a.item.name < b.item.name
    )

    # Create inventory rows for each display entry
    for entry in display_entries:
        var row = INVENTORY_ROW_SCENE.instantiate() as InventoryRow
        inventory_list.add_child(row)

        # Setup the row with appropriate display name
        var display_name = entry.item.name
        if entry.description_suffix:
            display_name += " " + entry.description_suffix

        # Use a modified setup that handles the display name
        row.setup_with_custom_name(entry.item, entry.count, is_combat_disabled, display_name, entry.instance_data, entry.is_equipped)

        # Connect signals
        row.item_selected.connect(_on_item_selected)
        row.item_used.connect(_on_item_used)

        inventory_rows.append(row)

    inventory_updated.emit()

func _on_item_selected(item: Item) -> void:
    selected_item = item

    # Update visual selection on all rows
    for row in inventory_rows:
        row.set_selected(row.item_resource == selected_item)

func _on_item_used(item: Item, item_data: ItemData) -> void:
    if item is ItemWeapon:
        # Check if this specific instance is equipped
        var is_this_equipped = (GameState.player.equipped_weapon == item and
                               GameState.player.equipped_weapon_data == item_data)

        if is_this_equipped:
            # Unequip the current weapon
            GameState.player.unequip_weapon()
        else:
            # Equip this weapon instance (either specific or from generic stack)
            GameState.player.equip_weapon(item, item_data)
    else:
        item.use()
        _refresh_inventory()

    item_used.emit()
