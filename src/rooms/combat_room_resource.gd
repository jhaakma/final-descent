class_name CombatRoomResource extends RoomResource

@export var enemy_list: Array[EnemyResource] = []

var selected_enemy: EnemyResource = null

func is_cleared_by_default() -> bool:
    return false

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    selected_enemy = enemy_list[GameState.rng.randi_range(0, enemy_list.size() - 1)]

    var fight_action := RoomAction.new("Fight", "Engage in combat with the %s" % selected_enemy.name)
    fight_action.is_enabled = true
    fight_action.perform_action = _on_fight_pressed

    add_action_button(_actions_grid, _room_screen, fight_action)

    var avoid_action := RoomAction.new("Avoid", "Try to sneak past the enemy (%.0f%% chance)" % (selected_enemy.avoid_chance * 100))
    avoid_action.is_enabled = true
    avoid_action.perform_action = _on_avoid_pressed
    add_action_button(_actions_grid, _room_screen, avoid_action)


func _on_avoid_pressed(room_screen: RoomScreen) -> void:
    print("Avoid chance: %f" % selected_enemy.avoid_chance)
    var roll := GameState.rng.randf()
    print("Avoid roll: %f" % roll)
    var avoided := roll < selected_enemy.avoid_chance
    if avoided:
        LogManager.log_event("{You} avoid the combat and move on.")
        room_screen.mark_cleared()
    else:
        start_avoid_failure_fight(room_screen)

func _on_fight_pressed(room_screen: RoomScreen) -> void:
    start_fight(room_screen, false)

func start_fight(room_screen: RoomScreen, enemy_first: bool) -> void:
    var popup: CombatPopup = CombatPopup.get_scene().instantiate()
    popup.set_enemy_first(enemy_first)
    popup.set_enemy(selected_enemy)
    room_screen.add_child(popup)

    # Connect turn_ended signal to update room screen at the end of each turn
    popup.turn_ended.connect(func()->void:
        room_screen.update()
    )

    popup.combat_resolved.connect(func(victory: bool)->void:
        if victory:
            var loot_data := selected_enemy.loot_component.generate_loot()
            popup.show_loot_screen(loot_data)
        else:
            # defeat handled by GameState (hp 0), but we can still mark
            # defeat handled by GameState (hp 0), but we can still mark
            pass)
    popup.combat_fled.connect(func()->void:
        # Player fled successfully - just mark room as cleared, no loot
        room_screen.mark_cleared())
    popup.loot_collected.connect(func()->void:
        room_screen.mark_cleared())

func start_avoid_failure_fight(room_screen: RoomScreen) -> void:
    var popup: CombatPopup = CombatPopup.get_scene().instantiate()
    popup.set_enemy_first(true)
    popup.set_avoid_failure(true)
    popup.set_enemy(selected_enemy)
    room_screen.add_child(popup)

    # Connect turn_ended signal to update room screen at the end of each turn
    popup.turn_ended.connect(func()->void:
        room_screen.update()
    )

    popup.combat_resolved.connect(func(victory: bool)->void:
        if victory:
            var loot_data := selected_enemy.loot_component.generate_loot()
            popup.show_loot_screen(loot_data)
        else:
            # defeat handled by GameState (hp 0), but we can still mark
            pass)
    popup.combat_fled.connect(func()->void:
        # Player fled successfully - just mark room as cleared, no loot
        room_screen.mark_cleared())
    popup.loot_collected.connect(func()->void:
        room_screen.mark_cleared())
