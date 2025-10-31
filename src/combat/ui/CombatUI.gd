class_name CombatUI extends RefCounted
## Pure UI component that responds to combat state changes
## No combat logic - only handles presentation and user input forwarding

signal attack_requested()
signal defend_requested()
signal flee_requested()

# UI element references (will be set by InlineCombat)
var label: Label
var resistance_label: RichTextLabel
var weakness_label: RichTextLabel
var stats_label: RichTextLabel
var you_bar: ProgressBar
var foe_bar: ProgressBar
var attack_btn: Button
var defend_btn: Button
var flee_btn: Button

var context: CombatContext

func setup_ui_references(ui_refs: Dictionary) -> void:
    ## Set up references to UI elements
    label = ui_refs.get("label")
    resistance_label = ui_refs.get("resistance_label")
    weakness_label = ui_refs.get("weakness_label")
    stats_label = ui_refs.get("stats_label")
    you_bar = ui_refs.get("you_bar")
    foe_bar = ui_refs.get("foe_bar")
    attack_btn = ui_refs.get("attack_btn")
    defend_btn = ui_refs.get("defend_btn")
    flee_btn = ui_refs.get("flee_btn")

    # Connect button signals
    if attack_btn:
        attack_btn.pressed.connect(_on_attack_button_pressed)
    if defend_btn:
        defend_btn.pressed.connect(_on_defend_button_pressed)
    if flee_btn:
        flee_btn.pressed.connect(_on_flee_button_pressed)

func initialize_combat_display(combat_context: CombatContext) -> void:
    context = combat_context
    var enemy_name := context.enemy.get_name()

    if label:
        label.text = "%s appears!" % [_get_a_an(enemy_name).capitalize()]

    _update_resistance_labels()
    _update_weakness_labels()
    _update_enemy_stats_display()
    _refresh_bars()

func update_display() -> void:
    ## Update all UI elements with current combat state
    _refresh_bars()
    _update_enemy_stats_display()
    _update_button_states()

func enable_actions() -> void:
    ## Enable action buttons for player turn
    if not context or not context.player.should_skip_turn():
        _set_buttons_enabled(true)
    else:
        _handle_player_turn_skip()

func disable_actions() -> void:
    ## Disable action buttons (e.g., during enemy turn)
    _set_buttons_enabled(false)

func _on_attack_button_pressed() -> void:
    attack_requested.emit()

func _on_defend_button_pressed() -> void:
    defend_requested.emit()

func _on_flee_button_pressed() -> void:
    flee_requested.emit()

func _set_buttons_enabled(enabled: bool) -> void:
    if attack_btn:
        attack_btn.disabled = not enabled
    if defend_btn:
        defend_btn.disabled = not enabled
    if flee_btn:
        flee_btn.disabled = not enabled

func _handle_player_turn_skip() -> void:
    _set_buttons_enabled(false)
    LogManager.log_event("{You} are stunned and skip {your} turn!", {"target": context.player})

func _update_button_states() -> void:
    if context and context.player.should_skip_turn():
        _set_buttons_enabled(false)
    else:
        _set_buttons_enabled(true)

func _refresh_bars() -> void:
    if not context:
        return

    # Trigger player stats update
    context.player.stats_changed.emit()

    # Update enemy health bar
    if foe_bar:
        foe_bar.max_value = context.enemy.get_max_hp()
        foe_bar.value = context.enemy.get_current_hp()

    # Update tooltips with status effects
    if you_bar:
        var player_tooltip := "HP: %d/%d" % [context.player.get_hp(), context.player.get_max_hp()]
        var player_effects_desc := context.player.get_status_effects_description()
        if player_effects_desc != "":
            player_tooltip += "\n%s" % player_effects_desc
        you_bar.tooltip_text = player_tooltip

    if foe_bar:
        var enemy_tooltip := "HP: %d/%d" % [context.enemy.get_current_hp(), context.enemy.get_max_hp()]
        var enemy_effects_desc := context.enemy.get_status_effects_description()
        if enemy_effects_desc != "":
            enemy_tooltip += "\n%s" % enemy_effects_desc
        foe_bar.tooltip_text = enemy_tooltip

func _update_resistance_labels() -> void:
    if not resistance_label or not context:
        return

    resistance_label.text = ""
    var resistances := context.enemy.get_resistances()
    if resistances.size() > 0:
        resistance_label.text = "Resistances: "
        for i in range(resistances.size()):
            var damage_type := resistances[i]
            var color := DamageType.get_type_color(damage_type).to_html()
            resistance_label.text += "[color=%s]%s[/color] " % [color, DamageType.get_type_name((damage_type))]
        #strip trailing space
        resistance_label.text = resistance_label.text.strip_edges()


func _update_weakness_labels() -> void:
    if not weakness_label or not context:
        return

    weakness_label.text = ""
    var weaknesses := context.enemy.get_weaknesses()
    if weaknesses.size() > 0:
        weakness_label.text = "Weaknesses: "
        for i in range(weaknesses.size()):
            var damage_type := weaknesses[i]
            var color := DamageType.get_type_color(damage_type).to_html()
            weakness_label.text += "[color=%s]%s[/color] " % [color, DamageType.get_type_name((damage_type))]
        #strip trailing space
        weakness_label.text = weakness_label.text.strip_edges()

func _update_enemy_stats_display() -> void:
    if not stats_label or not context:
        return

    var attack_power := context.enemy.get_total_attack_power()
    var current_defense := context.enemy.get_current_defense_percentage()
    var defend_bonus := context.enemy.get_defend_bonus_percentage()
    var attack_bonus := context.enemy.get_attack_bonus()
    var defense_bonus := context.enemy.get_defense_bonus()

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

func _get_a_an(_name: String) -> String:
    var vowels := ["a", "e", "i", "o", "u"]
    if _name.length() > 0 and _name[0].to_lower() in vowels:
        return "an %s" % _name
    else:
        return "a %s" % _name