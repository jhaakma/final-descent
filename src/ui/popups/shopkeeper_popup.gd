class_name ShopkeeperPopup extends BasePopup
signal shop_closed()

@onready var greeting_label: Label = %GreetingLabel
@onready var player_gold_label: Label = %PlayerGoldLabel
@onready var shopkeeper_gold_label: Label = %ShopkeeperGoldLabel
@onready var shop_tabs: TabContainer = %ShopTabs
@onready var items_for_sale_list: VBoxContainer = %ItemsForSaleList
@onready var player_items_list: VBoxContainer = %PlayerItemsList
@onready var close_btn: Button = %CloseBtn

var inventory_row_scene: PackedScene = InventoryRow.get_scene()
var items_for_sale: Array[ItemStack] = []
var shopkeeper_gold: int = 0

static func get_scene() -> PackedScene:
    return load("uid://b7atjuptp522r") as PackedScene

func _ready() -> void:
    # Enable auto-wrapping to content size
    wrap_controls = true

    close_btn.pressed.connect(_on_close_shop)
    # Update gold display when stats change
    GameState.stats_changed.connect(_update_gold_display)
    GameState.player.inventory_changed.connect(_update_inventory_display)

    # Center the popup on screen
    _center_on_screen()

func show_shop(loot_result: LootComponent.LootResult, greeting: String) -> void:
    greeting_label.text = greeting
    items_for_sale = loot_result.items_gained
    shopkeeper_gold = loot_result.gold_total
    _update()

    # Ensure window resizes to fit content
    await get_tree().process_frame  # Wait one frame for layout to complete
    reset_size()  # Reset to minimum size needed for content

    # Re-center after resizing
    _center_on_screen()

func _update() -> void:
    _update_gold_display()
    _setup_buy_tab()
    _setup_sell_tab()

func _update_gold_display() -> void:
    if player_gold_label:
        player_gold_label.text = "Your Gold: %d" % GameState.player.gold
    if shopkeeper_gold_label:
        shopkeeper_gold_label.text = "Shopkeeper Gold: %d" % shopkeeper_gold

func _setup_buy_tab() -> void:
    # Clear existing items
    for child in items_for_sale_list.get_children():
        child.queue_free()

    if items_for_sale.is_empty():
        var no_items_label: Label = Label.new()
        no_items_label.text = "No items for sale."
        items_for_sale_list.add_child(no_items_label)
        return

    # Add each item for sale
    for stack in items_for_sale:
        var tiles := stack.get_item_tiles()
        for tile in tiles:
            print("Adding item for sale: %s" % stack.item.name)
            var item_info: InventoryRow = inventory_row_scene.instantiate()
            item_info.setup_for_shop(tile, InventoryRow.DisplayMode.SHOP_BUY, shopkeeper_gold)
            item_info.item_bought.connect(_on_buy_item)
            items_for_sale_list.add_child(item_info)

func _setup_sell_tab() -> void:
    _update_inventory_display()

func _update_inventory_display() -> void:
    if not player_items_list:
        return



    # Clear existing items immediately
    for child in player_items_list.get_children():
        player_items_list.remove_child(child)
        child.queue_free()

    if GameState.player.inventory.is_empty():
        var no_items_label: Label = Label.new()
        no_items_label.text = "No items to sell."
        player_items_list.add_child(no_items_label)
        return

    # Get ItemTiles from player (includes equipped items for selling)
    var all_tiles: Array[ItemInstance] = GameState.player.get_item_tiles()
    var equipped_tiles: Array[ItemInstance] = []
    var unequipped_tiles: Array[ItemInstance] = []

    # Separate equipped and unequipped items
    for tile: ItemInstance in all_tiles:
        if tile.item is Equippable and tile.is_equipped:
            equipped_tiles.append(tile)
        else:
            unequipped_tiles.append(tile)

    # Combine with equipped items first (at the top)
    var inventory_tiles: Array[ItemInstance] = equipped_tiles + unequipped_tiles

    for tile: ItemInstance in inventory_tiles:
        var item_container: InventoryRow = inventory_row_scene.instantiate()
        item_container.setup_for_shop(
            tile,
            InventoryRow.DisplayMode.SHOP_SELL,
            shopkeeper_gold
        )
        item_container.item_sold.connect(_on_sell_item)
        player_items_list.add_child(item_container)

func _on_buy_item(item_instance: ItemInstance) -> void:
    var purchase_value:= item_instance.item.calculate_buy_value(item_instance.item_data)
    if GameState.player.gold >= purchase_value:
        GameState.player.add_gold(-purchase_value)
        GameState.player.add_items(ItemInstance.new(item_instance.item, item_instance.item_data, 1))
        shopkeeper_gold += purchase_value

        # find item stack and decrease count
        for stack in items_for_sale:
            if stack.item == item_instance.item:
                stack.remove_instance_by_reference(item_instance.item_data)

        LogManager.log_event("Bought %s for %d gold" % [item_instance.item.name, purchase_value])
        # Update displays and refresh the buy tab
        _update()

func _on_sell_item(item_instance: ItemInstance) -> void:
    var sell_value: int = item_instance.item.calculate_sell_value(item_instance.item_data)

    # Check if shopkeeper can afford this item
    if shopkeeper_gold < sell_value:
        LogManager.log_event("Shopkeeper cannot afford %s (needs %d gold)" % [item_instance.item.name, sell_value])
        return

    GameState.player.remove_item(item_instance)
    GameState.player.add_gold(sell_value)
    shopkeeper_gold -= sell_value
    # Add to shopkeeper's inventory
    var found_stack := false
    for stack in items_for_sale:
        if stack.item == item_instance.item:
            stack.add_instance(item_instance.item_data)
            found_stack = true
            break
    if not found_stack:
        print("Creating new stack for sold item: %s" % item_instance.item.name)
        if item_instance.item_data:
            # Item has unique data - create stack with count 0, add_instance will increment it
            var new_stack := ItemStack.new(item_instance.item, 0)
            new_stack.add_instance(item_instance.item_data)
            items_for_sale.append(new_stack)
        else:
            # Generic item - create stack with count 1
            var new_stack := ItemStack.new(item_instance.item, 1)
            items_for_sale.append(new_stack)
    LogManager.log_event("Sold %s for %d gold" % [item_instance.item.name, sell_value])

    # Update displays
    _update()

func _on_close_shop() -> void:
    emit_signal("shop_closed")
    queue_free()
