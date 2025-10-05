class_name ShopkeeperPopup extends BasePopup
signal shop_closed()

@onready var greeting_label: Label = %GreetingLabel
@onready var player_gold_label: Label = %PlayerGoldLabel
@onready var shopkeeper_gold_label: Label = %ShopkeeperGoldLabel
@onready var shop_tabs: TabContainer = %ShopTabs
@onready var items_for_sale_list: VBoxContainer = %ItemsForSaleList
@onready var player_items_list: VBoxContainer = %PlayerItemsList
@onready var close_btn: Button = %CloseBtn

var shop_item_row_scene = preload("res://uielements/shop_item/ShopItemRow.tscn")
var shopkeeper_name: String
var items_for_sale: Array[Item] = []
var shopkeeper_gold: int = 0

func _ready() -> void:
    # Enable auto-wrapping to content size
    wrap_controls = true

    close_btn.pressed.connect(_on_close_shop)
    # Update gold display when stats change
    GameState.stats_changed.connect(_update_gold_display)
    GameState.player.inventory_changed.connect(_update_inventory_display)

    # Center the popup on screen
    _center_on_screen()

func show_shop(loot_result: LootComponent.LootResult, merchant_name: String, greeting: String) -> void:
    shopkeeper_name = merchant_name
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
        var no_items_label = Label.new()
        no_items_label.text = "No items for sale."
        items_for_sale_list.add_child(no_items_label)
        return

    # Add each item for sale
    for item in items_for_sale:
        print("Adding item for sale: %s" % item.name)
        var item_info = shop_item_row_scene.instantiate()
        item_info.setup(item, 1, true, shopkeeper_gold < item.purchase_value)
        item_info.buy_item.connect(_on_buy_item)
        items_for_sale_list.add_child(item_info)

func _setup_sell_tab() -> void:
    _update_inventory_display()

func _update_inventory_display() -> void:
    if not player_items_list:
        return

    # Clear existing items
    for child in player_items_list.get_children():
        child.queue_free()

    if GameState.player.inventory.is_empty():
        var no_items_label = Label.new()
        no_items_label.text = "No items to sell."
        player_items_list.add_child(no_items_label)
        return

    # Add each item in inventory
    for item in GameState.player.inventory.keys():
        var quantity = GameState.player.inventory[item]
        var item_container = shop_item_row_scene.instantiate()
        item_container.setup(item, quantity, false, shopkeeper_gold < item.get_sell_value())
        item_container.sell_item.connect(_on_sell_item)
        player_items_list.add_child(item_container)

func _on_buy_item(item: Item) -> void:
    if GameState.player.gold >= item.purchase_value:
        GameState.add_gold(-item.purchase_value)
        GameState.add_item(item)
        shopkeeper_gold += item.purchase_value
        LogManager.log_success("Bought %s for %d gold" % [item.name, item.purchase_value])

        # Update displays and refresh the buy tab
        _update()

func _on_sell_item(item: Item) -> void:
    if item in GameState.player.inventory and GameState.player.inventory[item] > 0:
        var sell_value = item.get_sell_value()

        # Check if shopkeeper can afford this item
        if shopkeeper_gold < sell_value:
            LogManager.log_warning("Shopkeeper cannot afford %s (needs %d gold)" % [item.name, sell_value])
            return

        # Complete the transaction
        GameState.remove_item(item)
        GameState.add_gold(sell_value)
        shopkeeper_gold -= sell_value
        LogManager.log_success("Sold %s for %d gold" % [item.name, sell_value])

        # Update displays
        _update()

func _on_close_shop() -> void:
    emit_signal("shop_closed")
    queue_free()
