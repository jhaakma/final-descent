class_name ShrineRoomResource extends RoomResource

@export var blessing_cost: int = 10
@export var cure_cost: int = 5  # Cost to pray for cure (same as blessing for now)
@export var heal_cost: int = 8  # Cost to pray for healing
@export var blessings: Array[StatusCondition] = []  # Status effects for blessings
@export var heal_amount: int = 10  # Amount healed when praying for healing
@export var loot_component: LootComponent = LootComponent.new()
@export var loot_curse_chance: float = 0.3  # Chance to receive a curse when looting
@export var curse_enemy: EnemyResource = null  # Enemy to spawn if cursed

func is_cleared_by_default() -> bool:
    return true

func build_actions(actions_grid: GridContainer, room_screen: RoomScreen) -> void:

    var blessing := RoomAction.new("Blessing (%d gold)" % blessing_cost, "Pray for a random beneficial buff")
    blessing.is_enabled = GameState.player.has_gold(blessing_cost)
    blessing.perform_action = _on_blessing
    add_action_button(actions_grid, room_screen, blessing)

    var restoration := RoomAction.new("Restoration (%d gold)" % cure_cost, "Pray to remove all negative status effects")
    restoration.is_enabled = GameState.player.has_gold(cure_cost)
    restoration.perform_action = _on_cure
    add_action_button(actions_grid, room_screen, restoration)

    var heal := RoomAction.new("Healing (%d gold)" % heal_cost, "Pray to restore some hitpoints")
    heal.is_enabled = GameState.player.has_gold(heal_cost)
    heal.perform_action = _on_heal
    add_action_button(actions_grid, room_screen, heal)

    var looting := RoomAction.new("Loot the Shrine", "Search the shrine for treasure, but risk upsetting the spirits")
    looting.is_enabled = true
    looting.perform_action = _on_loot
    add_action_button(actions_grid, room_screen, looting)


func _on_blessing(room_screen: RoomScreen) -> void:
    if not GameState.player.has_gold(blessing_cost):
        LogManager.log_warning("Not enough gold.")
        return
    GameState.player.add_gold(-blessing_cost)

    # Grant a random status effect
    if blessings.size() > 0:
        LogManager.log_success("You pray at the shrine and feel blessed!")
        var chosen_blessing: StatusCondition = blessings[GameState.rng.randi() % blessings.size()]
        GameState.player.apply_status_condition(chosen_blessing)
        room_screen.update()
    else:
        LogManager.log_message("You pray at the shrine, but nothing happens.")
    room_screen.mark_cleared()

#Cure removes any status effects
func _on_cure(room_screen: RoomScreen) -> void:
    if not GameState.player.has_gold(cure_cost):
        LogManager.log_warning("Not enough gold.")
        return

    LogManager.log_success("You pray at the shrine and feel cleansed!")
    var removed_effects := GameState.player.clear_all_negative_status_effects()
    if removed_effects.size() > 0:
        GameState.player.add_gold(-cure_cost)
        room_screen.update()
        room_screen.mark_cleared()
    else:
        LogManager.log_warning("You have no status effects to cure.")


func _on_heal(room_screen: RoomScreen) -> void:
    if not GameState.player.has_gold(heal_cost):
        LogManager.log_warning("Not enough gold.")
        return
    GameState.player.add_gold(-heal_cost)
    GameState.player.heal(heal_amount)
    LogManager.log_success("You pray at the shrine and heal %d HP." % heal_amount)
    room_screen.update()
    room_screen.mark_cleared()

func _on_loot(room_screen: RoomScreen) -> void:
    var loot_data := loot_component.generate_loot()
    # DIf curse triggers, start combat with ghost
    if GameState.rng.randf() < loot_curse_chance:
        var ghost_enemy: EnemyResource = curse_enemy
        if ghost_enemy != null:
            LogManager.log_combat("As you loot the shrine, a vengeful spirit appears!")
            var popup: CombatPopup = CombatPopup.get_scene().instantiate()
            popup.set_enemy(ghost_enemy)
            room_screen.add_child(popup)
            popup.combat_resolved.connect(func(victory: bool)->void:
                if victory:
                    popup.show_loot_screen(loot_data)
                    room_screen.mark_cleared()
                else:
                    # defeat handled by GameState (hp 0), but we can still mark
                    pass)
            popup.combat_fled.connect(func()-> void:
                # Player fled from ghost - just mark room as cleared, no loot
                room_screen.mark_cleared())
            popup.loot_collected.connect(func()-> void:
                room_screen.mark_cleared())
            return
        else:
            LogManager.log_warning("Error: No ghost enemy configured!")

    var gold := loot_component.generate_loot().gold_total
    GameState.player.add_gold(gold)
    LogManager.log_success("You loot the shrine and gain %d gold." % gold)
    room_screen.mark_cleared()
