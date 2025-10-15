# popups/CombatPopup.gd
class_name CombatPopup extends BasePopup
signal combat_resolved(victory: bool)
signal combat_fled()
signal loot_collected()
signal turn_ended()

@onready var label: Label = %EnemyLabel
@onready var resistance_label: RichTextLabel = %EnemyResistances
@onready var weakness_label: RichTextLabel = %EnemyWeaknesses
@onready var stats_label: RichTextLabel = %EnemyStats  # TODO: Add EnemyStats RichTextLabel to scene
@onready var you_bar: ProgressBar = %PlayerHP
@onready var foe_bar: ProgressBar = %EnemyHP
@onready var attack_btn: Button = %AttackBtn
@onready var defend_btn: Button = %DefendBtn
@onready var flee_btn: Button = %FleeBtn
@onready var use_btn: MenuButton = %UseItemBtn

var current_enemy: Enemy
var enemy_resource: EnemyResource
var enemy_first: bool = false
var avoid_failure: bool = false
var death_delay_timer: Timer = null
# Mapping of menu item indices to ItemTiles to prevent index mismatches
var use_item_menu_mapping: Array[ItemInstance] = []

static func get_scene() -> PackedScene:
    return load("uid://in5kt0j6adyh") as PackedScene

func set_enemy(enemy_res: EnemyResource) -> void:
    enemy_resource = enemy_res

func set_enemy_first(value: bool) -> void:
    enemy_first = value

func set_avoid_failure(value: bool) -> void:
    avoid_failure = value

func get_a_an(_name: String) -> String:
    var vowels := ["a", "e", "i", "o", "u"]
    if _name.length() > 0 and _name[0].to_lower() in vowels:
        return "an %s" % _name
    else:
        return "a %s" % _name

func _ready() -> void:
    if enemy_resource == null:
        push_error("CombatPopup: enemy_resource must be set before adding to scene tree")
        return

    current_enemy = Enemy.new(enemy_resource)
    var enemy_name := current_enemy.get_name()
    current_enemy.action_performed.connect(_on_enemy_action)
    label.text = "%s appears!" % [get_a_an(enemy_name).capitalize()]

    # Update resistance labels
    resistance_label.text = ""
    var resistances := current_enemy.get_resistances()
    if resistances.size() > 0:
        resistance_label.text = "Resistances: "
        for i in range(resistances.size()):
            var damage_type := resistances[i]
            var color := DamageType.get_type_color(damage_type).to_html()
            resistance_label.text += "[color=%s]%s[/color]" % [color, DamageType.get_type_name((damage_type))]


    weakness_label.text = ""
    var weaknesses := current_enemy.get_weaknesses()
    if weaknesses.size() > 0:
        weakness_label.text = "Weaknesses: "
        for i in range(weaknesses.size()):
            var damage_type := weaknesses[i]
            var color := DamageType.get_type_color(damage_type).to_html()
            weakness_label.text += "[color=%s]%s[/color]" % [color, DamageType.get_type_name((damage_type))]

    # Update stats display (attack and defense)
    _update_enemy_stats_display()


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
        get_tree().create_timer(0.5).timeout.connect(func()->void:
            _enemy_turn()
            _check_end_with_delay()
        )

    # Center the popup on screen
    _center_on_screen()

    # Check if player should skip their first turn due to existing stun
    if not enemy_first:
        _enable_action_buttons()  # This will check for stun and handle it

func _disable_action_buttons() -> void:
    attack_btn.disabled = true
    defend_btn.disabled = true
    flee_btn.disabled = true
    use_btn.disabled = true

func _enable_action_buttons() -> void:
    # Update button states based on stun status
    # If player is stunned, this will automatically process the stunned turn
    if GameState.player.should_skip_turn():
        _check_player_turn_skip()
        return

    # Enable all buttons normally
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
    var player_tooltip := "HP: %d/%d" % [GameState.player.get_hp(), GameState.player.get_max_hp()]
    var player_effects_desc := GameState.player.get_status_effects_description()
    if player_effects_desc != "":
        player_tooltip += "\n%s" % player_effects_desc
    you_bar.tooltip_text = player_tooltip

    var enemy_tooltip := "HP: %d/%d" % [current_enemy.get_current_hp(), current_enemy.get_max_hp()]
    var enemy_effects_desc := current_enemy.get_status_effects_description()
    if enemy_effects_desc != "":
        enemy_tooltip += "\n%s" % enemy_effects_desc
    foe_bar.tooltip_text = enemy_tooltip

    # Update button states based on player stun status
    _update_button_states()

    # Update enemy stats display in case they changed due to status effects
    _update_enemy_stats_display()

func _update_enemy_stats_display() -> void:
    # Display enemy attack and defense stats in a concise format
    if stats_label:  # Check if the label exists in the scene
        var attack_power := current_enemy.get_total_attack_power()
        var defense := current_enemy.get_total_defense()
        var attack_bonus := current_enemy.get_attack_bonus()
        var defense_bonus := current_enemy.get_defense_bonus()

        # Build the stats text with bonuses if they exist
        var stats_text := "ATK: %d" % attack_power
        if attack_bonus > 0:
            stats_text += " [color=green](+%d)[/color]" % attack_bonus
        elif attack_bonus < 0:
            stats_text += " [color=red](%d)[/color]" % attack_bonus

        stats_text += " | DEF: %d" % defense
        if defense_bonus > 0:
            stats_text += " [color=green](+%d)[/color]" % defense_bonus
        elif defense_bonus < 0:
            stats_text += " [color=red](%d)[/color]" % defense_bonus

        stats_label.text = stats_text

func _update_button_states() -> void:
    # Disable buttons if player is stunned, enable if not
    var is_stunned: bool = GameState.player.should_skip_turn()
    attack_btn.disabled = is_stunned
    defend_btn.disabled = is_stunned
    flee_btn.disabled = is_stunned
    use_btn.disabled = is_stunned

func _setup_use_item_menu() -> void:
    var _popup := use_btn.get_popup()
    _popup.clear()
    use_item_menu_mapping.clear()

    # Get ItemTiles from player
    var all_tiles: Array[ItemInstance] = GameState.player.get_item_tiles()

    # Filter to only include inventory items (exclude equipped items in combat menu)
    var inventory_tiles: Array[ItemInstance] = []
    for tile: ItemInstance in all_tiles:
        if not tile.is_equipped:
            inventory_tiles.append(tile)

    # Sort tiles alphabetically by name (with instances after generic items for same type)
    inventory_tiles.sort_custom(func(a: ItemInstance, b: ItemInstance) -> bool:
        return a.get_sort_key() < b.get_sort_key()
    )

    # Build the popup menu and mapping
    for tile: ItemInstance in inventory_tiles:
        _popup.add_item(tile.get_full_display_name())
        use_item_menu_mapping.append(tile)

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
    var loot_popup: LootPopup= LootPopup.get_scene().instantiate()
    get_parent().add_child(loot_popup)
    loot_popup.show_loot(loot_data, "You search the remains and find:")

    # Connect the loot collected signal - forward it and then clean up
    loot_popup.loot_collected.connect(func()-> void:
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
            GameState.player.take_damage(value)
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
    # Check if enemy should skip their turn BEFORE processing status effects
    if current_enemy.should_skip_turn():
        LogManager.log_combat("%s is stunned and skips their turn!" % current_enemy.get_name())
        # Process status effects after skipping turn (this will tick down the stun)
        _process_status_effects()
        # Refresh bars to show updated status effects
        _refresh_bars()
        # Check if player should skip their turn after enemy turn ended
        _check_player_turn_skip()
        return

    # Process status effects at start of turn (for non-stunned enemies)
    _process_status_effects()

    if current_enemy.is_alive():
        # Execute enemy action (handles both continuing multi-turn abilities and new actions)
        current_enemy.perform_action()

        # Immediately refresh bars after enemy action to show any newly applied status effects
        _refresh_bars()

        # Check if player should skip their turn after enemy action
        _check_player_turn_skip()

func _check_player_turn_skip() -> void:
    # Check if player should skip their turn (e.g., due to stun)
    if GameState.player.should_skip_turn():
        LogManager.log_combat("You are stunned and skip your turn!")
        # Disable buttons temporarily to show turn was skipped
        _disable_action_buttons()
        # After a brief delay, continue to enemy turn (buttons will be updated based on stun status)
        get_tree().create_timer(1.0).timeout.connect(func()->void:
            _enemy_turn()
            _check_end()
            # Emit turn_ended signal for stunned player turn
            emit_signal("turn_ended")
        )

func _process_status_effects() -> void:
    # Process player status effects
    GameState.player.process_status_effects()

    # Process enemy status effects
    current_enemy.process_status_effects()

    # Update button states after processing status effects
    _update_button_states()

func resolve_turn() -> void:
    """Unified method to handle all end-of-turn logic and emit turn_ended signal"""
    # Check if combat has ended before processing turn
    if not current_enemy.is_alive() or GameState.player.get_hp() <= 0:
        _check_end()
        return

    # If combat is still ongoing, trigger enemy turn
    _enemy_turn()

    # Check end conditions after enemy turn
    _check_end()

    # Emit turn_ended signal to notify room screen to update
    emit_signal("turn_ended")


func _on_attack() -> void:
    var total_dmg := GameState.player.get_total_attack_power()
    var player_damage_type := GameState.player.get_attack_damage_type()
    var final_damage := current_enemy.calculate_incoming_damage(total_dmg, player_damage_type)
    current_enemy.take_damage(final_damage)
    var weapon_instance := GameState.player.get_equipped_weapon_instance()
    var weapon_name := weapon_instance.item.name if weapon_instance else ""

    LogManager.log_attack(GameState.player, current_enemy, final_damage, weapon_name, player_damage_type)
    if weapon_instance:
        # Check if weapon has special attack effects
        var weapon := weapon_instance.item as Weapon
        weapon.on_attack_hit(current_enemy)

    # Reduce weapon condition after logging the attack
    GameState.player.reduce_weapon_condition()

    # Use unified turn resolution
    resolve_turn()

func _on_defend() -> void:
    # Use the shared defend ability for consistency
    var defend_ability := DefendAbility.new()
    defend_ability.execute(GameState.player)

    # Use unified turn resolution
    resolve_turn()

func _on_flee() -> void:
    var success := randf() < current_enemy.resource.avoid_chance
    LogManager.log_flee_attempt(GameState.player, success)

    if success:
        emit_signal("combat_fled")
        queue_free()
    else:
        # Use unified turn resolution when flee fails
        resolve_turn()

func _on_use_item_index(idx: int) -> void:
    print("DEBUG: _on_use_item_index called with index: ", idx)

    # Check if the index is valid in our mapping
    if idx < 0 or idx >= use_item_menu_mapping.size():
        LogManager.log_message("Nothing happens…")
        # Use unified turn resolution
        resolve_turn()
        return

    # Get the ItemInstance from our mapping
    var tile: ItemInstance = use_item_menu_mapping[idx]

    print("DEBUG: Using item: %s, is_unique_instance: %s" % [tile.item.name, tile.is_unique_instance()])

    # Check if the item is still available
    if not tile.is_available_in_inventory():
        print("Item %s (or specific instance) is no longer available" % tile.item.name)
        # Refresh the use item menu to reflect updated quantities
        _setup_use_item_menu()
        # Use unified turn resolution
        resolve_turn()
        return

    # Use the item through the tile's use_item method
    if tile.use_item():
        print("Successfully used item: %s" % tile.item.name)
    else:
        print("Failed to use item: %s" % tile.item.name)

    # Refresh the use item menu to reflect updated quantities
    _setup_use_item_menu()
    # Use unified turn resolution
    resolve_turn()
