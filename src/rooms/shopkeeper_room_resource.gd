class_name ShopkeeperRoomResource extends RoomResource

@export var loot_component: LootComponent

var loot_result: LootComponent.LootResult = null

func is_cleared_by_default() -> bool:
    return true

func build_actions(actions_grid: GridContainer, room_screen: RoomScreen) -> void:
    loot_result = loot_component.generate_loot()

    var talk_action := RoomAction.new("Talk to the Merchant")
    talk_action.is_enabled = true
    talk_action.perform_action = _on_talk_to_shopkeeper

    add_action_button(actions_grid, room_screen, talk_action)

func _on_talk_to_shopkeeper(room_screen: RoomScreen) -> void:
    # Show the shopkeeper popup
    var shopkeeper_popup: ShopkeeperPopup = ShopkeeperPopup.get_scene().instantiate()
    room_screen.add_child(shopkeeper_popup)
    shopkeeper_popup.show_shop(loot_result, title)
    # Connect the shop closed signal to allow leaving the room
    shopkeeper_popup.shop_closed.connect(_on_shop_closed.bind(room_screen))

func _on_shop_closed(_room_screen: RoomScreen) -> void:
    # Player can continue after shopping
    pass
