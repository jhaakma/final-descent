class_name InventoryComponent extends Node

## Component for handling inventory UI and interactions
##
## This component manages the inventory list, item selection, and item usage.
## It encapsulates all inventory-related functionality to promote single responsibility
## and componentization as per the project guidelines.

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

    # Prepare inventory items, sort by name, equipped item first
    var inventory_items := []
    var equipped_item := GameState.player.equipped_weapon

    for item in GameState.player.inventory.keys():
        inventory_items.append(item)

    inventory_items.sort_custom(func(a, b):
        # Equipped item comes first
        if a == equipped_item:
            return true
        if b == equipped_item:
            return false
        return a.name < b.name
    )

    # Create new inventory rows
    for item in inventory_items:
        var count = GameState.player.inventory[item]
        var row = INVENTORY_ROW_SCENE.instantiate() as InventoryRow

        inventory_list.add_child(row)
        row.setup(item, count, is_combat_disabled)

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

func _on_item_used(item: Item) -> void:
    if item is ItemWeapon:
        # Weapons can be equipped/unequipped even during combat
        if GameState.player.equipped_weapon == item:
            # Unequip the weapon
            GameState.unequip_weapon()
        else:
            # Equip the weapon (this will automatically unequip any current weapon)
            GameState.equip_weapon(item)
    else:
        item.use()
        _refresh_inventory()

    item_used.emit()
