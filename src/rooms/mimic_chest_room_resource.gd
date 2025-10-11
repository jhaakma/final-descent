class_name MimicChestRoomResource extends RoomResource

@export var mimic_enemy: EnemyResource

func is_cleared_by_default() -> bool:
    return true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    var open_chest_action := RoomAction.new("Open Chest", "Open the chest to see what's inside")
    open_chest_action.is_enabled = true
    open_chest_action.perform_action = _on_open_chest
    add_action_button(_actions_grid, _room_screen, open_chest_action)

func _on_open_chest(room_screen: RoomScreen) -> void:
    # Instead of giving loot, trigger combat with the mimic
    LogManager.log_combat("The chest suddenly springs to life! It's a mimic!")

    if mimic_enemy == null:
        LogManager.log_warning("Error: No mimic enemy configured!")
        room_screen.mark_cleared()
        return

    print("Spawning mimic enemy: %s" % mimic_enemy.name)
    var popup: CombatPopup = CombatPopup.get_scene().instantiate()
    popup.set_enemy(mimic_enemy)
    room_screen.add_child(popup)
    popup.combat_resolved.connect(_on_mimic_combat_resolved.bind(room_screen, popup))
    popup.combat_fled.connect(func()->void:
        # Player fled from mimic - just mark room as cleared, no loot
        room_screen.mark_cleared())
    popup.loot_collected.connect(func()->void:
        room_screen.mark_cleared())

func _on_mimic_combat_resolved(victory: bool, _room_screen: RoomScreen, popup: CombatPopup) -> void:
    if victory:
        var enemy_loot_data := mimic_enemy.loot_component.generate_loot()
        popup.show_loot_screen(enemy_loot_data)
    else:
        # defeat handled by GameState (hp 0), but we can still mark
        pass
