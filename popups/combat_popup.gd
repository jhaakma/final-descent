# popups/CombatPopup.gd
class_name CombatPopup extends BasePopup
signal combat_resolved(victory: bool)
signal combat_fled()
signal loot_collected()

@onready var you_bar: ProgressBar = %PlayerHP
@onready var foe_bar: ProgressBar = %EnemyHP
@onready var label: Label = %EnemyLabel
@onready var attack_btn: Button = %AttackBtn
@onready var defend_btn: Button = %DefendBtn
@onready var flee_btn: Button = %FleeBtn
@onready var use_btn: MenuButton = %UseItemBtn

var current_enemy: Enemy
var enemy_resource: EnemyResource
var enemy_first: bool = false
var avoid_failure: bool = false
var death_delay_timer: Timer = null

func set_enemy(enemy_res: EnemyResource) -> void:
    enemy_resource = enemy_res

func set_enemy_first(value: bool) -> void:
    enemy_first = value

func set_avoid_failure(value: bool) -> void:
    avoid_failure = value

func get_a_an(_name: String) -> String:
    var vowels = ["a", "e", "i", "o", "u"]
    if _name.length() > 0 and _name[0].to_lower() in vowels:
        return "an %s" % _name
    else:
        return "a %s" % _name

func _ready() -> void:
    if enemy_resource == null:
        push_error("CombatPopup: enemy_resource must be set before adding to scene tree")
        return

    current_enemy = Enemy.new(enemy_resource)
    var enemy_name = current_enemy.get_name()
    current_enemy.action_performed.connect(_on_enemy_action)
    label.text = "%s appears!" % [get_a_an(enemy_name).capitalize()]

    LogManager.log_combat("Encounter: %s (HP %d)" % [current_enemy.get_name(), current_enemy.get_max_hp()])
    _refresh_bars()
    _setup_use_item_menu()
    attack_btn.pressed.connect(_on_attack)
    defend_btn.pressed.connect(_on_defend)
    flee_btn.pressed.connect(_on_flee)

    # Plan the enemy's first action based on starting HP
    current_enemy.plan_action()

    # If enemy_first is true, give the enemy an immediate attack before normal combat
    if enemy_first:
        # Disable buttons during the surprise attack
        _disable_action_buttons()

        if avoid_failure:
            LogManager.log_warning("You fail to avoid!")
            LogManager.log_combat("The %s strikes first!" % current_enemy.get_name())
        else:
            LogManager.log_combat("The %s strikes first!" % current_enemy.get_name())

        # Add a small delay before the enemy attack to let the player see what's happening
        get_tree().create_timer(0.5).timeout.connect(func():
            _enemy_turn()
            _check_end_with_delay()
        )

    # Center the popup on screen
    _center_on_screen()

func _disable_action_buttons() -> void:
    attack_btn.disabled = true
    defend_btn.disabled = true
    flee_btn.disabled = true
    use_btn.disabled = true

func _enable_action_buttons() -> void:
    attack_btn.disabled = false
    defend_btn.disabled = false
    flee_btn.disabled = false
    use_btn.disabled = false


func _refresh_bars() -> void:
    you_bar.max_value = GameState.player.get_max_hp()
    you_bar.value = GameState.player.get_hp()
    foe_bar.max_value = current_enemy.get_max_hp()
    foe_bar.value = current_enemy.get_current_hp()

    # Update tooltips with status effects
    var player_tooltip = "HP: %d/%d" % [GameState.player.get_hp(), GameState.player.get_max_hp()]
    var player_effects_desc = GameState.get_player_status_effects_description()
    if player_effects_desc != "":
        player_tooltip += "\n%s" % player_effects_desc
    you_bar.tooltip_text = player_tooltip

    var enemy_tooltip = "HP: %d/%d" % [current_enemy.get_current_hp(), current_enemy.get_max_hp()]
    var enemy_effects_desc = current_enemy.get_status_effects_description()
    if enemy_effects_desc != "":
        enemy_tooltip += "\n%s" % enemy_effects_desc
    foe_bar.tooltip_text = enemy_tooltip

func _setup_use_item_menu() -> void:
    var _popup := use_btn.get_popup()
    _popup.clear()
    for item in GameState.player.inventory.keys():
        var quantity = GameState.player.inventory[item]
        _popup.add_item("%s (%d)" % [item.name, quantity])

    # Disconnect the signal if it's already connected to avoid duplicate connections
    if _popup.index_pressed.is_connected(_on_use_item_index):
        _popup.index_pressed.disconnect(_on_use_item_index)
    _popup.index_pressed.connect(_on_use_item_index)

func _check_end() -> void:
    if not current_enemy.is_alive():
        LogManager.log_success("You defeated the %s!" % current_enemy.get_name())
        emit_signal("combat_resolved", true)
        # Don't queue_free() here - let the loot screen handle it
    elif GameState.player.get_hp() <= 0:
        # Disable buttons to prevent input during death sequence
        _disable_action_buttons()
        # Death delay is now handled in Player.take_damage
        emit_signal("combat_resolved", false)
        queue_free()
    else:
        _refresh_bars()

func _check_end_with_delay() -> void:
    if not current_enemy.is_alive():
        LogManager.log_success("You defeated the %s!" % current_enemy.get_name())
        emit_signal("combat_resolved", true)
        # Don't queue_free() here - let the loot screen handle it
    elif GameState.player.get_hp() <= 0:
        # Disable buttons to prevent input during death sequence
        _disable_action_buttons()
        # Death delay is now handled in Player.take_damage
        emit_signal("combat_resolved", false)
        queue_free()
    else:
        # Player survived the surprise attack, re-enable buttons for normal combat
        _enable_action_buttons()
        _refresh_bars()

func show_loot_screen(loot_data: LootComponent.LootResult ) -> void:
    visible = false
    exclusive = false  # Allow interaction with loot popup

    # Create and show the loot popup
    var loot_popup = load("res://popups/LootPopup.tscn").instantiate()
    get_parent().add_child(loot_popup)
    loot_popup.show_loot(loot_data, "You search the remains and find:")

    # Connect the loot collected signal - forward it and then clean up
    loot_popup.loot_collected.connect(func():
        emit_signal("loot_collected")
        # Now it's safe to free the combat popup
        queue_free()
    )

    # Don't free the combat popup immediately - wait for victory popup to finish

func _on_enemy_action(action_type: String, value: int, message: String) -> void:
    # Message is now handled by the enemy's enhanced logging
    # Only log if there's still a message (for backwards compatibility)
    if message != "":
        LogManager.log_combat(message)

    match action_type:
        "attack":
            GameState.take_damage(value)
        "defend":
            # Enemy is now defending, no immediate effect
            pass
        "flee_success":
            emit_signal("combat_fled")  # Enemy fled, no loot
            queue_free()
        "flee_fail":
            # Enemy failed to flee and attacks instead
            pass

func _enemy_turn() -> void:
    # Process status effects at start of turn
    _process_status_effects()

    if current_enemy.is_alive():
        # Execute the action that was planned at the start of the turn
        current_enemy.perform_planned_action()

        # Immediately refresh bars after enemy action to show any newly applied status effects
        _refresh_bars()

        # Plan the next action for the next turn (if enemy is still alive)
        if current_enemy.is_alive():
            current_enemy.plan_action()

func _process_status_effects() -> void:
    # Process player status effects
    var player_results = GameState.process_player_status_effects()
    for result in player_results:
        # Only log if there's a message (for backwards compatibility with older effects)
        if result.message != "":
            LogManager.log_message(result.message)

    # Process player buff turns
    GameState.process_buff_turns()

    # Process enemy status effects
    var enemy_results = current_enemy.process_status_effects()
    for result in enemy_results:
        # Only log if there's a message (for backwards compatibility with older effects)
        if result.message != "":
            LogManager.log_message(result.message)


func _on_attack() -> void:
    var total_dmg = GameState.player.calculate_attack_damage()
    var final_damage = current_enemy.calculate_incoming_damage(total_dmg)
    current_enemy.take_damage(final_damage)

    var attack_message: String
    if GameState.player.has_weapon_equipped():
        attack_message = "You strike with %s for %d damage." % [GameState.player.get_weapon_name(), final_damage]

        # Check if weapon has special attack effects
        var weapon = GameState.player.equipped_weapon
        if weapon.has_method("on_attack_hit"):
            weapon.on_attack_hit(current_enemy)
    else:
        attack_message = "You strike for %d damage." % final_damage

    LogManager.log_combat(attack_message)

    if current_enemy.is_alive():
        _enemy_turn()
    _check_end()

func _on_defend() -> void:
    # Add temporary defense bonus for this turn
    var defend_bonus = GameState.player.calculate_defend_bonus()
    GameState.player.add_temporary_defense_bonus(defend_bonus)

    # Use enhanced logging
    LogManager.log_defend(GameState.player)

    _enemy_turn()
    # Remove the temporary defense bonus after the enemy's turn
    GameState.player.remove_temporary_defense_bonus(defend_bonus)

func _on_flee() -> void:
    var success = randf() < current_enemy.resource.avoid_chance
    LogManager.log_flee_attempt(GameState.player, success)

    if success:
        emit_signal("combat_fled")
        queue_free()
    else:
        _enemy_turn()
        _check_end()

func _on_use_item_index(idx: int) -> void:
    var inventory_keys = GameState.player.inventory.keys()
    if idx >= 0 and idx < inventory_keys.size():
        var item: Item = inventory_keys[idx]

        # Use the item's use method
        item.use()

        # Refresh the use item menu to reflect updated quantities
        _setup_use_item_menu()
    else:
        LogManager.log_message("Nothing happens…")

    _enemy_turn()
    _check_end()
