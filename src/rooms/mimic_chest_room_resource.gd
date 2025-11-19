class_name MimicChestRoomResource extends RoomResource

@export var mimic_enemy: EnemyResource
@export var loot_component: LootComponent
@export var button_label: String = "Open Chest"
@export var button_tooltip: String = "Open the chest to see what's inside"

func is_cleared_by_default() -> bool:
    return true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    var open_chest_action := RoomAction.new(button_label, button_tooltip)
    open_chest_action.is_enabled = true
    open_chest_action.perform_action = _on_open_chest
    add_action_button(_actions_grid, _room_screen, open_chest_action)

func _on_open_chest(room_screen: RoomScreen) -> void:
    # Instead of giving loot, trigger combat with the mimic
    LogManager.log_event("The chest suddenly springs to life! It's a mimic!")

    if mimic_enemy == null:
        LogManager.log_event("Error: No mimic enemy configured!")
        room_screen.mark_cleared()
        return

    print("Spawning mimic enemy: %s" % mimic_enemy.name)
    var combat_scene: PackedScene = load("res://src/ui/components/InlineCombat.tscn")
    var inline_combat: Control = combat_scene.instantiate()
    inline_combat.call("set_enemy", mimic_enemy)
    room_screen.show_inline_content(inline_combat)

    if inline_combat.has_signal("combat_resolved"):
        inline_combat.connect("combat_resolved", _on_mimic_combat_resolved.bind(room_screen, inline_combat))
    if inline_combat.has_signal("combat_fled"):
        inline_combat.connect("combat_fled", func()->void:
            # Player fled from mimic - just mark room as cleared, no loot
            room_screen.mark_cleared())

    if inline_combat.has_signal("loot_collected"):
        inline_combat.connect("loot_collected", func()->void:
            room_screen.mark_cleared())

func _on_mimic_combat_resolved(victory: bool, room_screen: RoomScreen, inline_combat: Control) -> void:
    if victory:
        var loot := loot_component
        if loot == null:
            loot = mimic_enemy.loot_component
        var loot_result := loot.generate_loot()
        inline_combat.call("show_loot_screen", loot_result)
    else:
        # defeat handled by GameState (hp 0), but we can still mark
        pass
    room_screen.mark_cleared()
