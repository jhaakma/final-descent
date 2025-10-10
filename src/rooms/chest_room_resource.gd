class_name ChestRoomResource extends RoomResource

@export var chance_empty: float = 0.2
@export var loot_component: LootComponent

func _init():
    cleared_by_default = true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    add_action_button(_actions_grid, ActionButton.new("Open Chest", "Open the chest to see what's inside"), _on_open_chest.bind(_room_screen))

func _on_open_chest(room_screen: RoomScreen) -> void:
    # Look for a LootComponent node first, fallback to legacy loot_table
    var loot_data := loot_component.generate_loot()

    # Show the loot popup
    var loot_popup : LootPopup= load("res://data/ui/popups/LootPopup.tscn").instantiate()
    room_screen.add_child(loot_popup)
    loot_popup.show_loot(loot_data, "You open the chest and find:")

    # Connect the loot collected signal to mark room as cleared
    loot_popup.loot_collected.connect(room_screen.mark_cleared)
