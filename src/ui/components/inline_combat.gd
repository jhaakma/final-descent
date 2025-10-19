class_name InlineCombat extends InlineContentBase
## Displays combat interface directly in the room container

signal combat_resolved(victory: bool)
signal combat_fled()
signal loot_collected()
signal turn_ended()

@onready var label: Label = %EnemyLabel
@onready var resistance_label: RichTextLabel = %EnemyResistances
@onready var weakness_label: RichTextLabel = %EnemyWeaknesses
@onready var stats_label: RichTextLabel = %EnemyStats
@onready var you_bar: ProgressBar = %PlayerHP
@onready var foe_bar: ProgressBar = %EnemyHP
@onready var attack_btn: Button = %AttackBtn
@onready var defend_btn: Button = %DefendBtn
@onready var flee_btn: Button = %FleeBtn

var current_enemy: Enemy
var enemy_resource: EnemyResource
var enemy_first: bool = false
var avoid_failure: bool = false
var death_delay_timer: Timer = null

static func get_scene() -> PackedScene:
    return load("uid://jne75qvyltc6") as PackedScene  # Will need to create this scene

func set_enemy(enemy_res: EnemyResource) -> void:
    enemy_resource = enemy_res
    # Initialize combat if we're ready
    if is_inside_tree():
        _initialize_combat()

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
    # Initialize combat if enemy resource is already set
    if enemy_resource:
        _initialize_combat()

func _initialize_combat() -> void:
    if not enemy_resource:
        return

    # Wait for nodes to be ready if needed
    if not label:
        await ready

    current_enemy = Enemy.new(enemy_resource)
    var enemy_name := current_enemy.get_name()
    current_enemy.action_performed.connect(_on_enemy_action)

    label.text = "%s appears!" % [get_a_an(enemy_name).capitalize()]

    # Register combat state with GameState
    GameState.start_combat(current_enemy)

    # Update resistance labels
    _update_resistance_labels()
    _update_weakness_labels()
    _update_enemy_stats_display()

    LogManager.log_event("Encounter: {enemy:%s} (HP %d)" % [current_enemy.get_name(), current_enemy.get_max_hp()])
    _refresh_bars()

    # Connect buttons
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
            LogManager.log_event("{You} fail to avoid!", {"target": GameState.player})
            LogManager.log_event("The {enemy:%s} strikes first!" % current_enemy.get_name())
        else:
            LogManager.log_event("The {enemy:%s} strikes first!" % current_enemy.get_name())

        # Add a small delay before the enemy attack
        get_tree().create_timer(0.5).timeout.connect(func()->void:
            _enemy_turn()
            _check_end_with_delay()
        )
    else:
        _enable_action_buttons()

func show_content() -> void:
    super.show_content()
    # Check if player should skip their first turn due to existing stun
    if not enemy_first:
        _enable_action_buttons()  # This will check for stun and handle it

func cleanup() -> void:
    super.cleanup()
    # Clean up combat state when combat is destroyed
    GameState.end_combat()

func _update_resistance_labels() -> void:
    resistance_label.text = ""
    var resistances := current_enemy.get_resistances()
    if resistances.size() > 0:
        resistance_label.text = "Resistances: "
        for i in range(resistances.size()):
            var damage_type := resistances[i]
            var color := DamageType.get_type_color(damage_type).to_html()
            resistance_label.text += "[color=%s]%s[/color]" % [color, DamageType.get_type_name((damage_type))]

func _update_weakness_labels() -> void:
    weakness_label.text = ""
    var weaknesses := current_enemy.get_weaknesses()
    if weaknesses.size() > 0:
        weakness_label.text = "Weaknesses: "
        for i in range(weaknesses.size()):
            var damage_type := weaknesses[i]
            var color := DamageType.get_type_color(damage_type).to_html()
            weakness_label.text += "[color=%s]%s[/color]" % [color, DamageType.get_type_name((damage_type))]

func _disable_action_buttons() -> void:
    attack_btn.disabled = true
    defend_btn.disabled = true
    flee_btn.disabled = true

func _enable_action_buttons() -> void:
    # Update button states based on stun status
    if GameState.player.should_skip_turn():
        _check_player_turn_skip()
        return

    # Enable all buttons normally
    attack_btn.disabled = false
    defend_btn.disabled = false
    flee_btn.disabled = false

func _refresh_bars() -> void:
    GameState.player.stats_changed.emit()

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
    _update_enemy_stats_display()

func _update_enemy_stats_display() -> void:
    if stats_label:
        var attack_power := current_enemy.get_total_attack_power()
        var current_defense := current_enemy.get_current_defense_percentage()
        var defend_bonus := current_enemy.get_defend_bonus_percentage()
        var attack_bonus := current_enemy.get_attack_bonus()
        var defense_bonus := current_enemy.get_defense_bonus()

        # Build the stats text with bonuses if they exist
        var stats_text := "ATK: %d" % attack_power
        if attack_bonus > 0:
            stats_text += " [color=green](+%d)[/color]" % attack_bonus
        elif attack_bonus < 0:
            stats_text += " [color=red](%d)[/color]" % attack_bonus

        # Show defense with defend bonus if defending
        if defend_bonus > 0:
            stats_text += " | DEF: %d%% [color=cyan](+%d%% defending)[/color]" % [current_defense, defend_bonus]
        else:
            stats_text += " | DEF: %d%%" % current_defense
            if defense_bonus > 0:
                stats_text += " [color=green](+%d%%)[/color]" % defense_bonus
            elif defense_bonus < 0:
                stats_text += " [color=red](-%d%%)[/color]" % abs(defense_bonus)

        stats_label.text = stats_text

func _update_button_states() -> void:
    # Disable buttons if player is stunned, enable if not
    var is_stunned: bool = GameState.player.should_skip_turn()
    attack_btn.disabled = is_stunned
    defend_btn.disabled = is_stunned
    flee_btn.disabled = is_stunned

# Combat action methods (copied from CombatPopup)
func _on_attack() -> void:
    # Process player status effects at start of turn
    _process_start_of_player_turn_effects()

    var total_dmg := GameState.player.get_total_attack_power()
    var player_damage_type := GameState.player.get_attack_damage_type()
    var final_damage := current_enemy.calculate_incoming_damage(total_dmg, player_damage_type)
    current_enemy.take_damage(final_damage)
    var weapon_instance := GameState.player.get_equipped_weapon_instance()
    var weapon_name := weapon_instance.item.name if weapon_instance else ""

    # Log the attack
    if weapon_name != "":
        LogManager.log_event("{You} {action} {enemy:%s} with %s for {damage:%d}!" % [current_enemy.get_name(), weapon_name, final_damage], {"target": GameState.player, "damage_type": player_damage_type, "action": ["strike", "strikes"]})
    else:
        LogManager.log_event("{You} {action} {enemy:%s} for {damage:%d}!" % [current_enemy.get_name(), final_damage], {"target": GameState.player, "damage_type": player_damage_type, "action": ["attack", "attacks"]})
    if weapon_instance:
        # Check if weapon has special attack effects
        var weapon := weapon_instance.item as Weapon
        weapon.on_attack_hit(current_enemy)

    # Reduce weapon condition after logging the attack
    GameState.player.reduce_weapon_condition()

    # Use unified turn resolution
    resolve_turn()

func _on_defend() -> void:
    # Process player status effects at start of turn
    _process_start_of_player_turn_effects()

    # Use the shared defend ability for consistency
    var defend_ability := DefendAbility.new()
    defend_ability.execute(GameState.player)

    # Use unified turn resolution
    resolve_turn()

func _on_flee() -> void:
    # Process player status effects at start of turn
    _process_start_of_player_turn_effects()

    var success := randf() < current_enemy.resource.avoid_chance
    if success:
        LogManager.log_event("{You} flee successfully!", {"target": GameState.player})
    else:
        LogManager.log_event("{You} fail to flee!", {"target": GameState.player})

    if success:
        emit_signal("combat_fled")
        emit_signal("content_resolved")
    else:
        # Use unified turn resolution when flee fails
        resolve_turn()

func _on_enemy_action(action_type: String, value: int, message: String) -> void:
    # Message is now handled by the enemy's enhanced logging
    # Only log if there's still a message (for backwards compatibility)
    if message != "":
        LogManager.log_event(message)

    match action_type:
        "attack":
            GameState.player.take_damage(value)
        "defend":
            # Enemy is now defending, no immediate effect
            pass
        "flee_success":
            emit_signal("combat_fled")
            emit_signal("content_resolved")
        "flee_fail":
            # Enemy failed to flee and attacks instead
            pass

func _enemy_turn() -> void:
    # Check if enemy should skip their turn BEFORE processing status effects
    if current_enemy.should_skip_turn():
        LogManager.log_event("{enemy:%s} is stunned and skips their turn!" % current_enemy.get_name())
        # Refresh bars to show updated status effects
        _refresh_bars()
        # Check if player should skip their turn after enemy turn ended
        _check_player_turn_skip()
        return

    # Process enemy status effects at start of their turn
    current_enemy.process_status_effects()

    if current_enemy.is_alive():
        # Execute enemy action (handles both continuing multi-turn abilities and new actions)
        current_enemy.perform_action()

        # Immediately refresh bars after enemy action to show any newly applied status effects
        _refresh_bars()

        # Check if player should skip their turn after enemy action
        _check_player_turn_skip()

func _check_end_with_delay() -> void:
    if not current_enemy.is_alive():
        LogManager.log_event("{You} {action} the {enemy:%s}!" % current_enemy.get_name(), {"target": GameState.player, "action": ["defeat", "defeats"]})
        emit_signal("combat_resolved", true)
        # Don't emit content_resolved here - let the loot screen handle it
    elif GameState.player.get_hp() <= 0:
        # Disable buttons to prevent input during death sequence
        _disable_action_buttons()
        # Death delay is now handled in Player.take_damage
        emit_signal("combat_resolved", false)
        emit_signal("content_resolved")
    else:
        # Player survived the surprise attack, re-enable buttons for normal combat
        _enable_action_buttons()
        _refresh_bars()

func _check_player_turn_skip() -> void:
    # Check if player should skip their turn (e.g., due to stun)
    if GameState.player.should_skip_turn():
        LogManager.log_event("{You} are stunned and skip {your} turn!", {"target": GameState.player})
        # Process player effects when their turn is skipped
        GameState.player.process_status_effects()
        # Disable buttons temporarily to show turn was skipped
        _disable_action_buttons()
        # After a brief delay, continue to enemy turn (buttons will be updated based on stun status)
        get_tree().create_timer(1.0).timeout.connect(func()->void:
            _enemy_turn()
            _check_end()
            # Emit turn_ended signal for stunned player turn
            emit_signal("turn_ended")
        )

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

func _process_start_of_player_turn_effects() -> void:
    # Process player status effects at the START of their turn
    # This ensures effects remain visible throughout the enemy turn
    GameState.player.process_status_effects()

    # Update button states and UI after processing player status effects
    _update_button_states()
    _refresh_bars()

func _check_end() -> void:
    if not current_enemy.is_alive():
        LogManager.log_event("{You} {action} the {enemy:%s}!" % current_enemy.get_name(), {"target": GameState.player, "action": ["defeat", "defeats"]})
        emit_signal("combat_resolved", true)
        # Don't emit content_resolved here - let the loot screen handle it
    elif GameState.player.get_hp() <= 0:
        # Disable buttons to prevent input during death sequence
        _disable_action_buttons()
        # Death delay is now handled in Player.take_damage
        emit_signal("combat_resolved", false)
        emit_signal("content_resolved")
    else:
        _refresh_bars()

func show_loot_screen(loot_data: LootComponent.LootResult) -> void:
    # Replace combat content with loot content
    if room_screen:
        var inline_loot := (load("res://src/ui/components/InlineLoot.tscn") as PackedScene).instantiate() as InlineLoot
        inline_loot.show_loot(loot_data, "You search the remains and find:")

        # Replace current content with loot content
        room_screen.show_inline_content(inline_loot)

        # Connect loot collected signal
        inline_loot.loot_collected.connect(func()->void:
            emit_signal("loot_collected")
        )
