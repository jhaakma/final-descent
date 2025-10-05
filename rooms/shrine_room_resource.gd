class_name ShrineRoomResource extends RoomResource

@export var blessing_cost: int = 10
@export var cure_cost: int = 5  # Cost to pray for cure (same as blessing for now)
@export var heal_cost: int = 8  # Cost to pray for healing
@export var possible_buffs: Array[Buff] = []
@export var heal_amount: int = 10  # Amount healed when praying for healing
@export var loot_component: LootComponent = LootComponent.new()
@export var loot_curse_chance: float = 0.3  # Chance to receive a curse when looting
@export var curse_enemy: EnemyResource = null  # Enemy to spawn if cursed
func _init():
    cleared_by_default = true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    add_action_button(_actions_grid, "Pray for Blessing (%d gold)" % blessing_cost, _on_pray.bind(_room_screen))
    add_action_button(_actions_grid, "Pray for Cure (%d gold)" % cure_cost, _on_cure.bind(_room_screen))  # Cure uses same logic as pray for now
    add_action_button(_actions_grid, "Pray for Healing (%d gold)" % heal_cost, on_heal.bind(_room_screen))
    add_action_button(_actions_grid, "Loot the Shrine", _on_loot.bind(_room_screen))

func _on_pray(room_screen: RoomScreen) -> void:
    if not GameState.has_gold(blessing_cost):
        LogManager.log_warning("Not enough gold.")
        return
    GameState.add_gold(-blessing_cost)
    # Grant a random buff from the possible buffs
    if possible_buffs.size() > 0:
        var random_buff = possible_buffs[GameState.rng.randi() % possible_buffs.size()]
        GameState.add_buff(random_buff)
        room_screen.update()
    else:
        LogManager.log_message("You pray at the shrine, but nothing happens.")
    room_screen.mark_cleared()

#Cure removes any status effects
func _on_cure(room_screen: RoomScreen) -> void:
    if not GameState.has_gold(cure_cost):
        LogManager.log_warning("Not enough gold.")
        return
    GameState.add_gold(-cure_cost)
    var removed_effects := GameState.player.clear_all_status_effects()
    if removed_effects.size() > 0:
        for effect in removed_effects:
            LogManager.log_success("Cured status effect: %s" % effect.effect_name)
    else:
        LogManager.log_message("You pray at the shrine, but you have no status effects to cure.")
    room_screen.update()
    room_screen.mark_cleared()

func on_heal(room_screen: RoomScreen) -> void:
    if not GameState.has_gold(heal_cost):
        LogManager.log_warning("Not enough gold.")
        return
    GameState.add_gold(-heal_cost)
    GameState.heal(heal_amount)
    LogManager.log_success("You pray at the shrine and heal %d HP." % heal_amount)
    room_screen.update()
    room_screen.mark_cleared()

func _on_loot(room_screen: RoomScreen) -> void:
    var loot_data = loot_component.generate_loot()

    # DIf curse triggers, start combat with ghost
    if GameState.rng.randf() < loot_curse_chance:
        var ghost_enemy: EnemyResource = curse_enemy
        if ghost_enemy != null:
            LogManager.log_combat("As you loot the shrine, a vengeful spirit appears!")
            var popup: CombatPopup = load("res://popups/CombatPopup.tscn").instantiate()
            popup.set_enemy(ghost_enemy)
            room_screen.add_child(popup)
            popup.combat_resolved.connect(func(victory: bool):
                if victory:
                    popup.show_loot_screen(loot_data)
                    room_screen.mark_cleared()
                else:
                    # defeat handled by GameState (hp 0), but we can still mark
                    pass)
            popup.combat_fled.connect(func():
                # Player fled from ghost - just mark room as cleared, no loot
                room_screen.mark_cleared())
            popup.loot_collected.connect(func():
                room_screen.mark_cleared())
            return
        else:
            LogManager.log_warning("Error: No ghost enemy configured!")

    var gold = loot_component.generate_loot().gold_total
    GameState.add_gold(gold)
    LogManager.log_success("You loot the shrine and gain %d gold." % gold)
    room_screen.mark_cleared()
