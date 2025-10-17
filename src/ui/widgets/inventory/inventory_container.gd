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

# Static variable to persist tab selection across room changes
static var preferred_tab_index: int = 0

@onready var tab_container: TabContainer = %TabContainer
@onready var all_list: VBoxContainer = %AllList
@onready var weapons_list: VBoxContainer = %WeaponsList
@onready var potions_list: VBoxContainer = %PotionsList
@onready var scrolls_list: VBoxContainer = %ScrollsList
@onready var misc_list: VBoxContainer = %MiscList

var selected_item: Item = null
var is_combat_disabled: bool = false
var inventory_rows: Dictionary[String, Array] = {
    "all": [] as Array[InventoryRow],
    "weapons": [] as Array[InventoryRow],
    "potions": [] as Array[InventoryRow],
    "scrolls": [] as Array[InventoryRow],
    "misc": [] as Array[InventoryRow]
}

# Preload the InventoryRow scene
var inventory_row_scene: PackedScene = InventoryRow.get_scene()

func _ready() -> void:
    # Connect to GameState inventory changes
    GameState.player.inventory_changed.connect(_refresh_inventory)

    # Connect to tab changes to remember the user's preference
    tab_container.tab_changed.connect(_on_tab_changed)

    # Set the initial tab to the user's preference
    tab_container.current_tab = preferred_tab_index

    # Initialize inventory display
    _refresh_inventory()

## Call this to refresh the inventory display
func refresh() -> void:
    _refresh_inventory()

## Set whether inventory usage is disabled (e.g., during combat)
func set_combat_disabled(disabled: bool) -> void:
    is_combat_disabled = disabled
    # Update all existing rows in all tabs
    for category_key: String in inventory_rows.keys():
        var rows: Array[InventoryRow] = inventory_rows[category_key]
        for row: InventoryRow in rows:
            row.set_combat_disabled(disabled)

## Get the currently selected item
func get_selected_item() -> Item:
    return selected_item


func _create_inventory_row(tile: ItemInstance) -> InventoryRow:
    var row: InventoryRow = inventory_row_scene.instantiate() as InventoryRow
    row.setup(tile, is_combat_disabled)
    row.item_selected.connect(_on_item_selected)
    row.item_used.connect(_on_item_used)
    return row

func _refresh_inventory() -> void:
    # Clear existing inventory rows from all tabs
    for category_key: String in inventory_rows.keys():
        var rows: Array[InventoryRow] = inventory_rows[category_key]
        for row: InventoryRow in rows:
            row.queue_free()
        rows.clear()

    selected_item = null

    # Get ItemTiles from player
    var all_tiles: Array[ItemInstance] = GameState.player.get_item_tiles()

    # Sort tiles: equipped first, then by name (with instances after generic items for same type)
    all_tiles.sort_custom(func(a: ItemInstance, b: ItemInstance) -> bool:
        return a.get_sort_key() < b.get_sort_key()
    )

    # Create inventory rows for each tile and organize by category
    for tile: ItemInstance in all_tiles:
        var row: InventoryRow = _create_inventory_row(tile)

        # Add to appropriate tab based on item category
        var category := tile.item.get_category()
        match category:
            Item.ItemCategory.WEAPON:
                weapons_list.add_child(row)
                inventory_rows["weapons"].append(row)
                if tile.is_equipped:
                    # If equipped, also add to other tabs
                    var potion_row: InventoryRow = _create_inventory_row(tile)
                    potions_list.add_child(potion_row)
                    inventory_rows["potions"].append(potion_row)

                    var scroll_row: InventoryRow = _create_inventory_row(tile)
                    scrolls_list.add_child(scroll_row)
                    inventory_rows["scrolls"].append(scroll_row)

                    var misc_row: InventoryRow = _create_inventory_row(tile)
                    misc_list.add_child(misc_row)
                    inventory_rows["misc"].append(misc_row)

            Item.ItemCategory.POTION:
                potions_list.add_child(row)
                inventory_rows["potions"].append(row)
            Item.ItemCategory.SCROLL:
                scrolls_list.add_child(row)
                inventory_rows["scrolls"].append(row)
            Item.ItemCategory.MISC:
                misc_list.add_child(row)
                inventory_rows["misc"].append(row)

        # Always add to "All" tab as well
        var all_row: InventoryRow = _create_inventory_row(tile)
        all_list.add_child(all_row)
        inventory_rows["all"].append(all_row)

    # Restore the user's preferred tab (deferred to ensure nodes are properly added)
    call_deferred("_restore_tab", preferred_tab_index)

    inventory_updated.emit()

func _on_tab_changed(tab_index: int) -> void:
    # Remember the user's preferred tab
    preferred_tab_index = tab_index

func _restore_tab(tab_index: int) -> void:
    tab_container.current_tab = tab_index

func _on_item_selected(item: Item) -> void:
    selected_item = item

    # Update visual selection on all rows across all tabs
    for category_key: String in inventory_rows.keys():
        var rows: Array[InventoryRow] = inventory_rows[category_key]
        for row: InventoryRow in rows:
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
