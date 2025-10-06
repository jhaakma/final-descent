class_name CombatComponent extends Node

signal combat_victory(loot_data: LootComponent.LootResult)
signal combat_defeat()
signal combat_fled()

# Combat state
var is_active: bool = false
var current_enemy: Enemy = null
var enemy_resource: EnemyResource = null
var enemy_first: bool = false
var avoid_failure: bool = false

# UI references (set by parent)
var actions_grid: GridContainer = null
var combat_container: Control = null
var enemy_health_bar: ProgressBar = null
var enemy_name_label: Label = null

# Storage for original room actions
var stored_room_actions: Array[Button] = []

func initialize(_actions_grid: GridContainer, _combat_container: Control, _enemy_health_bar: ProgressBar, _enemy_name_label: Label) -> void:
    """Initialize the combat component with UI references"""
    actions_grid = _actions_grid
    combat_container = _combat_container
    enemy_health_bar = _enemy_health_bar
    enemy_name_label = _enemy_name_label

func start_combat(enemy_res: EnemyResource, enemy_attacks_first: bool = false, is_avoid_failure: bool = false) -> void:
    """Start combat with the given enemy"""
    if is_active:
        LogManager.log_warning("Already in combat!")
        return

    # Set up combat state
    is_active = true
    enemy_resource = enemy_res
    enemy_first = enemy_attacks_first
    avoid_failure = is_avoid_failure
    current_enemy = Enemy.new(enemy_resource)
    current_enemy.action_performed.connect(_on_enemy_action)

    # Store current room actions before replacing them
    _store_room_actions()

    # Show combat UI
    _show_combat_ui()

    # Log combat start
    LogManager.log_combat("Encounter: %s (HP %d)" % [current_enemy.get_name(), current_enemy.get_max_hp()])

    # Plan the enemy's first action
    current_enemy.plan_action()

    # Handle enemy first strike if applicable
    if enemy_first:
        _disable_combat_buttons()

        if avoid_failure:
            LogManager.log_warning("You fail to avoid!")
            LogManager.log_combat("The %s strikes first!" % current_enemy.get_name())
        else:
            LogManager.log_combat("The %s strikes first!" % current_enemy.get_name())

        # Delay enemy attack to let player see what's happening
        get_tree().create_timer(0.5).timeout.connect(func():
            _enemy_turn()
            _check_combat_end()
        )

    # Update UI
    refresh_ui()

func end_combat() -> void:
    """Clean up combat state"""
    is_active = false
    if current_enemy and current_enemy.action_performed.is_connected(_on_enemy_action):
        current_enemy.action_performed.disconnect(_on_enemy_action)
    current_enemy = null
    enemy_resource = null
    _hide_combat_ui()
    _restore_room_actions()

func refresh_ui() -> void:
    """Update combat UI elements with current combat state"""
    if not is_active or not current_enemy:
        return

    # Update enemy health bar
    enemy_health_bar.max_value = current_enemy.get_max_hp()
    enemy_health_bar.value = current_enemy.get_current_hp()

    # Update enemy name and status
    var enemy_name = current_enemy.get_name()
    enemy_name_label.text = "%s appears!" % _get_a_an(enemy_name).capitalize()

    # Update tooltips with status effects
    var enemy_tooltip = "HP: %d/%d" % [current_enemy.get_current_hp(), current_enemy.get_max_hp()]
    var enemy_effects_desc = current_enemy.get_status_effects_description()
    if enemy_effects_desc != "":
        enemy_tooltip += "\n%s" % enemy_effects_desc
    enemy_health_bar.tooltip_text = enemy_tooltip

# ================================
# PRIVATE METHODS
# ================================

func _store_room_actions() -> void:
    """Store the current room action buttons before replacing with combat UI"""
    stored_room_actions.clear()
    for child in actions_grid.get_children():
        if child is Button:
            stored_room_actions.append(child)
            actions_grid.remove_child(child)

func _restore_room_actions() -> void:
    """Restore the original room action buttons after combat ends"""
    # Clear combat buttons
    for child in actions_grid.get_children():
        child.queue_free()

    # Restore original room buttons
    for button in stored_room_actions:
        actions_grid.add_child(button)
    stored_room_actions.clear()

func _show_combat_ui() -> void:
    """Replace Actions grid content with combat buttons and show enemy info"""
    # Clear existing actions
    for child in actions_grid.get_children():
        child.queue_free()

    # Show enemy UI elements
    combat_container.visible = true

    # Create combat action buttons
    var attack_btn = Button.new()
    attack_btn.text = "Attack"
    attack_btn.pressed.connect(_on_combat_attack)
    actions_grid.add_child(attack_btn)

    var defend_btn = Button.new()
    defend_btn.text = "Defend"
    defend_btn.pressed.connect(_on_combat_defend)
    actions_grid.add_child(defend_btn)

    var flee_btn = Button.new()
    flee_btn.text = "Flee"
    flee_btn.pressed.connect(_on_combat_flee)
    actions_grid.add_child(flee_btn)

    var use_item_combat_btn = MenuButton.new()
    use_item_combat_btn.text = "Use Item"
    _setup_combat_use_item_menu(use_item_combat_btn)
    actions_grid.add_child(use_item_combat_btn)

func _hide_combat_ui() -> void:
    """Hide combat-specific UI elements"""
    combat_container.visible = false

func _setup_combat_use_item_menu(use_btn: MenuButton) -> void:
    """Set up the use item menu for combat"""
    var popup := use_btn.get_popup()
    popup.clear()
    for item in GameState.player.inventory.keys():
        var quantity = GameState.player.inventory[item]
        popup.add_item("%s (%d)" % [item.name, quantity])
    popup.index_pressed.connect(_on_combat_use_item_index)

func _disable_combat_buttons() -> void:
    """Disable all combat action buttons"""
    for child in actions_grid.get_children():
        if child is Button or child is MenuButton:
            child.disabled = true

func _enable_combat_buttons() -> void:
    """Enable all combat action buttons"""
    for child in actions_grid.get_children():
        if child is Button or child is MenuButton:
            child.disabled = false

func _get_a_an(_name: String) -> String:
    """Helper function to get proper article (a/an) for enemy name"""
    var vowels = ["a", "e", "i", "o", "u"]
    if _name.length() > 0 and _name[0].to_lower() in vowels:
        return "an %s" % _name
    else:
        return "a %s" % _name

# ================================
# COMBAT ACTION HANDLERS
# ================================

func _on_combat_attack() -> void:
    """Handle player attack action"""
    var total_dmg = GameState.player.calculate_attack_damage()
    var final_damage = current_enemy.calculate_incoming_damage(total_dmg)
    current_enemy.take_damage(final_damage)

    # Use enhanced logging with target context
    var weapon_name = ""
    if GameState.player.has_weapon_equipped():
        weapon_name = GameState.player.get_weapon_name()
        # Check if weapon has special attack effects
        var weapon = GameState.player.equipped_weapon
        if weapon.has_method("on_attack_hit"):
            weapon.on_attack_hit(current_enemy)

    LogManager.log_attack(GameState.player, current_enemy, final_damage, weapon_name)

    if current_enemy.is_alive():
        _enemy_turn()
    _check_combat_end()

func _on_combat_defend() -> void:
    """Handle player defend action"""
    # Add temporary defense bonus for this turn
    var defend_bonus = GameState.player.calculate_defend_bonus()
    GameState.player.add_temporary_defense_bonus(defend_bonus)

    # Use enhanced logging
    LogManager.log_defend(GameState.player)

    _enemy_turn()

    # Remove the temporary defense bonus after the enemy's turn
    GameState.player.remove_temporary_defense_bonus(defend_bonus)
    _check_combat_end()

func _on_combat_flee() -> void:
    """Handle player flee action"""
    var success = randf() < current_enemy.resource.avoid_chance
    LogManager.log_flee_attempt(GameState.player, success)

    if success:
        _end_combat_fled()
    else:
        _enemy_turn()
        _check_combat_end()

func _on_combat_use_item_index(idx: int) -> void:
    """Handle player using an item during combat"""
    var inventory_keys = GameState.player.inventory.keys()
    if idx >= 0 and idx < inventory_keys.size():
        var item: Item = inventory_keys[idx]

        # Use the item's use method
        item.use()

        # Refresh the use item menu to reflect updated quantities
        for child in actions_grid.get_children():
            if child is MenuButton:
                _setup_combat_use_item_menu(child)
                break
    else:
        LogManager.log_message("Nothing happens…")

    _enemy_turn()
    _check_combat_end()

func _on_enemy_action(action_type: String, value: int, message: String) -> void:
    """Handle enemy actions"""
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
            _end_combat_fled()
        "flee_fail":
            # Enemy failed to flee and attacks instead
            pass

func _enemy_turn() -> void:
    """Execute enemy turn"""
    # Process status effects at start of turn
    _process_combat_status_effects()

    if current_enemy.is_alive():
        # Execute the action that was planned at the start of the turn
        current_enemy.perform_planned_action()

        # Immediately refresh UI after enemy action to show any newly applied status effects
        refresh_ui()

        # Plan the next action for the next turn (if enemy is still alive)
        if current_enemy.is_alive():
            current_enemy.plan_action()

func _process_combat_status_effects() -> void:
    """Process status effects for both player and enemy"""
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

func _check_combat_end() -> void:
    """Check if combat should end and handle victory/defeat"""
    if not current_enemy.is_alive():
        LogManager.log_success("You defeated the %s!" % current_enemy.get_name())
        _end_combat_victory()
    elif GameState.player.get_hp() <= 0:
        # Disable buttons to prevent input during death sequence
        _disable_combat_buttons()
        # Death delay is now handled in Player.take_damage
        _end_combat_defeat()
    else:
        # Player survived surprise attack, re-enable buttons for normal combat
        if enemy_first:
            _enable_combat_buttons()
        refresh_ui()

# ================================
# COMBAT END HANDLERS
# ================================

func _end_combat_victory() -> void:
    """Handle combat victory - emit signal with loot data"""
    var loot_data = enemy_resource.loot_component.generate_loot()
    end_combat()
    emit_signal("combat_victory", loot_data)

func _end_combat_defeat() -> void:
    """Handle combat defeat"""
    end_combat()
    emit_signal("combat_defeat")

func _end_combat_fled() -> void:
    """Handle successful flee from combat"""
    end_combat()
    emit_signal("combat_fled")
