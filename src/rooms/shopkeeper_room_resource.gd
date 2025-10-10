class_name ShopkeeperRoomResource extends RoomResource

@export var shopkeeper_name: String = "Merchant"
@export var greeting_message: String = "Welcome, traveler! What can I interest you in today?"
@export var loot_component: LootComponent

var loot_result: LootComponent.LootResult = null

func _init()->void:
    cleared_by_default = true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    loot_result = loot_component.generate_loot()
    add_action_button(_actions_grid, ActionButton.new("Talk to %s" % shopkeeper_name, "Browse the merchant's wares"), _on_talk_to_shopkeeper.bind(_room_screen))

func _on_talk_to_shopkeeper(room_screen: RoomScreen) -> void:
    # Show the shopkeeper popup
    var shopkeeper_popup: ShopkeeperPopup = ShopkeeperPopup.get_scene().instantiate()
    room_screen.add_child(shopkeeper_popup)

    shopkeeper_popup.show_shop(loot_result, shopkeeper_name, greeting_message)

    # Connect the shop closed signal to allow leaving the room
    shopkeeper_popup.shop_closed.connect(_on_shop_closed.bind(room_screen))

func _on_shop_closed(_room_screen: RoomScreen) -> void:
    # Player can continue after shopping
    pass
