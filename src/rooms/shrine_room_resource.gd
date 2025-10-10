class_name ShrineRoomResource extends RoomResource

@export var blessing_cost: int = 10
@export var cure_cost: int = 5  # Cost to pray for cure (same as blessing for now)
@export var heal_cost: int = 8  # Cost to pray for healing
@export var possible_status_effects: Array[StatusEffect] = []  # Status effects for blessings
@export var heal_amount: int = 10  # Amount healed when praying for healing
@export var loot_component: LootComponent = LootComponent.new()
@export var loot_curse_chance: float = 0.3  # Chance to receive a curse when looting
@export var curse_enemy: EnemyResource = null  # Enemy to spawn if cursed

func _init()->void:
    cleared_by_default = true

func build_actions(_actions_grid: GridContainer, _room_screen: RoomScreen) -> void:
    add_action_button(_actions_grid, ActionButton.new("Blessing (%d gold)" % blessing_cost, "Pray for a random beneficial buff"), _on_pray.bind(_room_screen))
    add_action_button(_actions_grid, ActionButton.new("Restoration (%d gold)" % cure_cost, "Pray to remove all negative status effects"), _on_cure.bind(_room_screen))  # Cure uses same logic as pray for now
    add_action_button(_actions_grid, ActionButton.new("Healing (%d gold)" % heal_cost, "Pray to restore some hitpoints"), on_heal.bind(_room_screen))
    add_action_button(_actions_grid, ActionButton.new("Loot the Shrine", "Search the shrine for treasure, but risk upsetting the spirits"), _on_loot.bind(_room_screen))


func _on_pray(room_screen: RoomScreen) -> void:
    if not GameState.has_gold(blessing_cost):
        LogManager.log_warning("Not enough gold.")
        return
    GameState.add_gold(-blessing_cost)

    # Grant a random status effect
    if possible_status_effects.size() > 0:
        LogManager.log_success("You pray at the shrine and feel blessed!")
        var random_effect: StatusEffect = possible_status_effects[GameState.rng.randi() % possible_status_effects.size()]
        var effect_copy: StatusEffect = random_effect.duplicate()
        GameState.player.apply_status_effect(effect_copy)
        room_screen.update()
    else:
        LogManager.log_message("You pray at the shrine, but nothing happens.")
    room_screen.mark_cleared()

#Cure removes any status effects
func _on_cure(room_screen: RoomScreen) -> void:
    if not GameState.has_gold(cure_cost):
        LogManager.log_warning("Not enough gold.")
        return

    var removed_effects := GameState.player.clear_all_negative_status_effects()
    if removed_effects.size() > 0:
        GameState.add_gold(-cure_cost)
        LogManager.log_success("You pray at the shrine and feel cleansed!")
        for effect in removed_effects:
            LogManager.log_success("Cured status effect: %s" % effect.effect_name)
        room_screen.update()
        room_screen.mark_cleared()
    else:
        LogManager.log_message("You have no status effects to cure.")


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
    var loot_data := loot_component.generate_loot()
    # DIf curse triggers, start combat with ghost
    if GameState.rng.randf() < loot_curse_chance:
        var ghost_enemy: EnemyResource = curse_enemy
        if ghost_enemy != null:
            LogManager.log_combat("As you loot the shrine, a vengeful spirit appears!")
            var popup: CombatPopup = Util.instantiate("res://data/ui/popups/CombatPopup.tscn")
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
    GameState.add_gold(gold)
    LogManager.log_success("You loot the shrine and gain %d gold." % gold)
    room_screen.mark_cleared()
