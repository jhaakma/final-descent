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
    var combat_scene: PackedScene = load("res://src/ui/components/InlineCombat.tscn")
    var inline_combat: Control = combat_scene.instantiate()
    inline_combat.call("set_enemy_first", enemy_first)
    inline_combat.call("set_enemy", selected_enemy)

    # Show the inline combat content
    room_screen.show_inline_content(inline_combat)

    # Connect turn_ended signal to update room screen at the end of each turn
    if inline_combat.has_signal("turn_ended"):
        inline_combat.connect("turn_ended", func()->void: room_screen.update())

    if inline_combat.has_signal("combat_resolved"):
        inline_combat.connect("combat_resolved", func(victory: bool)->void:
            if victory:
                var loot_data := selected_enemy.loot_component.generate_loot()
                inline_combat.call("show_loot_screen", loot_data)
            else:
                # defeat handled by GameState (hp 0), but we can still mark
                pass)

    if inline_combat.has_signal("combat_fled"):
        inline_combat.connect("combat_fled", func()->void:
            # Player fled successfully - just mark room as cleared, no loot
            room_screen.mark_cleared())

    if inline_combat.has_signal("loot_collected"):
        inline_combat.connect("loot_collected", func()->void:
            room_screen.mark_cleared())

func start_avoid_failure_fight(room_screen: RoomScreen) -> void:
    var combat_scene: PackedScene = load("res://src/ui/components/InlineCombat.tscn")
    var inline_combat: Control = combat_scene.instantiate()
    inline_combat.call("set_enemy_first", true)
    inline_combat.call("set_avoid_failure", true)
    inline_combat.call("set_enemy", selected_enemy)

    # Show the inline combat content
    room_screen.show_inline_content(inline_combat)

    # Connect turn_ended signal to update room screen at the end of each turn
    if inline_combat.has_signal("turn_ended"):
        inline_combat.connect("turn_ended", func()->void: room_screen.update())

    if inline_combat.has_signal("combat_resolved"):
        inline_combat.connect("combat_resolved", func(victory: bool)->void:
            if victory:
                var loot_data := selected_enemy.loot_component.generate_loot()
                inline_combat.call("show_loot_screen", loot_data)
            else:
                # defeat handled by GameState (hp 0), but we can still mark
                pass)

    if inline_combat.has_signal("combat_fled"):
        inline_combat.connect("combat_fled", func()->void:
            # Player fled successfully - just mark room as cleared, no loot
            room_screen.mark_cleared())

    if inline_combat.has_signal("loot_collected"):
        inline_combat.connect("loot_collected", func()->void:
            room_screen.mark_cleared())
