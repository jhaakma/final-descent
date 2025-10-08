class_name CombatRoomResource extends RoomResource

@export var enemy_list: Array[EnemyResource] = []

var selected_enemy: EnemyResource = null

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    selected_enemy = enemy_list[GameState.rng.randi_range(0, enemy_list.size() - 1)]
    add_action_button(_actions_grid, ActionButton.new("Fight", "Engage in combat with the %s" % selected_enemy.name), _on_fight_pressed.bind(_room_screen))
    add_action_button(_actions_grid, ActionButton.new("Avoid", "Try to sneak past the enemy (%.0f%% chance)" % (selected_enemy.avoid_chance * 100)), _on_avoid_pressed.bind(_room_screen))

func _on_avoid_pressed(room_screen: RoomScreen) -> void:
    print("Avoid chance: %f" % selected_enemy.avoid_chance)
    var roll = GameState.rng.randf()
    print("Avoid roll: %f" % roll)
    var avoided = roll < selected_enemy.avoid_chance
    if avoided:
        LogManager.log_success("You avoid the combat and move on.")
        room_screen.mark_cleared()
    else:
        start_avoid_failure_fight(room_screen)

func _on_fight_pressed(room_screen: RoomScreen) -> void:
    start_fight(room_screen, false)

func start_fight(room_screen: RoomScreen, enemy_first: bool) -> void:
    var popup: CombatPopup = load("res://popups/CombatPopup.tscn").instantiate()
    popup.set_enemy_first(enemy_first)
    popup.set_enemy(selected_enemy)
    room_screen.add_child(popup)
    popup.combat_resolved.connect(func(victory: bool):
        if victory:
            var loot_data = selected_enemy.loot_component.generate_loot()
            popup.show_loot_screen(loot_data)
        else:
            # defeat handled by GameState (hp 0), but we can still mark
            # defeat handled by GameState (hp 0), but we can still mark
            pass)
    popup.combat_fled.connect(func():
        # Player fled successfully - just mark room as cleared, no loot
        room_screen.mark_cleared())
    popup.loot_collected.connect(func():
        room_screen.mark_cleared())

func start_avoid_failure_fight(room_screen: RoomScreen) -> void:
    var popup: CombatPopup = load("res://popups/CombatPopup.tscn").instantiate()
    popup.set_enemy_first(true)
    popup.set_avoid_failure(true)
    popup.set_enemy(selected_enemy)
    room_screen.add_child(popup)
    popup.combat_resolved.connect(func(victory: bool):
        if victory:
            var loot_data = selected_enemy.loot_component.generate_loot()
            popup.show_loot_screen(loot_data)
        else:
            # defeat handled by GameState (hp 0), but we can still mark
            pass)
    popup.combat_fled.connect(func():
        # Player fled successfully - just mark room as cleared, no loot
        room_screen.mark_cleared())
    popup.loot_collected.connect(func():
        room_screen.mark_cleared())
