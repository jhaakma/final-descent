class_name InventoryContainer extends Node

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
var inventory_row_scene: PackedScene = InventoryRow.get_scene()

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

    # Get ItemTiles from player
    var all_tiles: Array[ItemInstance] = GameState.player.get_item_tiles()

    # Sort tiles: equipped first, then by name (with instances after generic items for same type)
    all_tiles.sort_custom(func(a: ItemInstance, b: ItemInstance) -> bool:
        return a.get_sort_key() < b.get_sort_key()
    )

    # Create inventory rows for each tile
    for tile: ItemInstance in all_tiles:
        var row: InventoryRow = inventory_row_scene.instantiate() as InventoryRow
        inventory_list.add_child(row)

        # Setup the row using the tile information
        row.setup(
            tile,
            is_combat_disabled
        )


        # Connect signals
        row.item_selected.connect(_on_item_selected)
        row.item_used.connect(_on_item_used)

        inventory_rows.append(row)

    inventory_updated.emit()

func _on_item_selected(item: Item) -> void:
    selected_item = item

    # Update visual selection on all rows
    for row in inventory_rows:
        row.set_selected(row.item_instance.item == selected_item)

func _on_item_used(item_instance: ItemInstance) -> void:
    if item_instance.item is Weapon:
        # Check if this specific instance is equipped
        var is_this_equipped: bool = item_instance.is_equipped

        if is_this_equipped:
            # Unequip the current weapon
            GameState.player.unequip_weapon()
        else:
            #If both equipped weapon and clicked weapon are the same generic item, ignore
            var equipped_weapon:= GameState.player.get_equipped_weapon()
            if equipped_weapon:
                var same_item:= equipped_weapon.item == item_instance.item
                var both_generic:= equipped_weapon.item_data == null and item_instance.item_data == null
                if same_item and both_generic:
                    print("Clicked weapon is already equipped (generic), ignoring.")
                    return

            # Equip this weapon instance (either specific or from generic stack)
            GameState.player.equip_weapon(item_instance)
    else:
        item_instance.use_item()
        _refresh_inventory()

    item_used.emit(item_instance)
