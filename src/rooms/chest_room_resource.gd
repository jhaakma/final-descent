class_name ChestRoomResource extends RoomResource

@export var chance_empty: float = 0.2
@export var loot_component: LootComponent

func is_cleared_by_default() -> bool:
    return true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    var open_chest_action := RoomAction.new("Open Chest", "Open the chest to see what's inside")
    open_chest_action.is_enabled = true
    open_chest_action.perform_action = _on_open_chest
    add_action_button(_actions_grid, _room_screen, open_chest_action)

func _on_open_chest(room_screen: RoomScreen) -> void:
    # Look for a LootComponent node first, fallback to legacy loot_table
    var loot_data := loot_component.generate_loot()

    # Show the inline loot
    var loot_scene: PackedScene = load("res://src/ui/components/InlineLoot.tscn")
    var inline_loot: Control = loot_scene.instantiate()
    inline_loot.call("show_loot", loot_data, "You open the chest and find:")
    room_screen.show_inline_content(inline_loot)

    # Connect the loot collected signal to mark room as cleared
    if inline_loot.has_signal("loot_collected"):
        inline_loot.connect("loot_collected", room_screen.mark_cleared)
