
extends Node

# Colors for different types of special parameters
class LogColors:
    static var HEALING: String = "#a1f7afff"  # Green
    static var BONUS: String = "#5dffffff"   # Light Blue
    static var ENEMY: String = "#ff5f2fff"    # Red
    static var DEFAULT: String = "#ffffffff"  # White
    static var COMBAT: String = "#f8e71cff"   # Yellow
    static var SUCCESS: String = "#7ed321ff"  # Bright Green
    static var WARNING: String = "#f5a623ff"  # Orange

# Special string patterns for contextual coloring and replacement:
# {player:text} - Colors text blue and replaces pronouns for player context
# {enemy:text} - Colors text red and replaces pronouns for enemy context
# {healing:amount} - Colors healing amount green
# {damage:amount:type} - Colors damage amount based on damage type (type is optional, defaults to PHYSICAL)
# {effect:name} - Colors effect name appropriately
# {action} - Chooses between player/non-player verb forms from context["action"] array: ["player_form", "non_player_form"]
# Standard patterns: {You}, {you}, {Your}, {your}, etc. for pronoun replacement

# Structure to store log entries with rich text formatting
class LogEntry:
    var rich_text: String

    func _init(log_rich_text: String) -> void:
        rich_text = log_rich_text

# Store log history to persist between rooms
var log_history: Array[LogEntry] = []
var max_log_entries: int = 100  # Limit log entries to prevent memory issues

# Track registered log displays for automatic updates
var registered_log_displays: Array[RichTextLabel] = []

# Register a log display for automatic updates
func register_log_display(log_label: RichTextLabel) -> void:
    if log_label not in registered_log_displays:
        registered_log_displays.append(log_label)
        # Immediately restore history to the new display
        restore_log_history(log_label)

# Unregister a log display
func unregister_log_display(log_label: RichTextLabel) -> void:
    var index := registered_log_displays.find(log_label)
    if index >= 0:
        registered_log_displays.remove_at(index)

# Update all registered log displays
func _update_all_displays() -> void:
    for log_label in registered_log_displays:
        if is_instance_valid(log_label):
            restore_log_history(log_label)
        else:
            # Remove invalid references
            var index := registered_log_displays.find(log_label)
            if index >= 0:
                registered_log_displays.remove_at(index)

# Main logging method - processes special patterns and adds formatted entry to history
func log_event(message: String, context: Dictionary = {}) -> void:
    var formatted_message := _process_message_patterns(message, context)
    if context.has("base_color"):
        formatted_message = "[color=%s]%s[/color]" % [context["base_color"], formatted_message]
    elif GameState.is_in_combat:
        formatted_message = "[color=%s]%s[/color]" % [LogColors.COMBAT, formatted_message]
    _add_to_history(formatted_message)
    _update_all_displays()

func log_success(message: String, context: Dictionary = {}) -> void:
    context["base_color"] = LogColors.SUCCESS
    log_event(message, context)

func log_warning(message: String, context: Dictionary = {}) -> void:
    context["base_color"] = LogColors.WARNING
    log_event(message, context)

# Process special string patterns in the message
func _process_message_patterns(message: String, context: Dictionary) -> String:
    var processed := message

    # Handle contextual pronoun replacement first
    var target: CombatEntity = context.get("target", null)
    if target == null:
        target = GameState.player
    processed = _replace_name_patterns(processed, target)
    # Process special coloring patterns
    processed = _process_player_patterns(processed, context)
    processed = _process_enemy_patterns(processed, context)
    processed = _process_healing_patterns(processed)
    processed = _process_damage_patterns(processed, context)
    processed = _process_effect_patterns(processed, context)
    processed = _process_effect_verb_patterns(processed, context)
    processed = _process_action_patterns(processed, context)

    return processed

func _replace_plural_patterns(text: String, count: int) -> String:
    var result := text
    if count == 1:
        result = result.replace("{is_are}", "is")
        result = result.replace("{has_have}", "has")
    else:
        result = result.replace("{is_are}", "are")
        result = result.replace("{has_have}", "have")
    return result


# Replace pronoun patterns based on target and add appropriate coloring
func _replace_name_patterns(text: String, target: CombatEntity) -> String:
    var is_player := target == GameState.player
    var result := text

    if is_player:
        # Player gets blue coloring - use format method for cleaner code
        result = result.replace("{You}", "You")
        result = result.replace("{you}", "you")
        result = result.replace("{Your}", "Your")
        result = result.replace("{your}", "your")
        result = result.replace("{You are}", "You are")
        result = result.replace("{you are}", "you are")
    else:
        # Enemy gets red coloring
        var target_name := target.get_name()
        var enemy_color := LogColors.ENEMY
        result = result.replace("{You}", "[color={color}]{name}[/color]".format({"color": enemy_color, "name": target_name}))
        result = result.replace("{you}", "[color={color}]{name}[/color]".format({"color": enemy_color, "name": target_name}))
        result = result.replace("{Your}", "[color={color}]{name}'s[/color]".format({"color": enemy_color, "name": target_name}))
        result = result.replace("{your}", "[color={color}]their[/color]").format({"color": enemy_color})
        result = result.replace("{You are}", "[color={color}]{name}[/color] is".format({"color": enemy_color, "name": target_name}))
        result = result.replace("{you are}", "[color={color}]{name}[/color] is".format({"color": enemy_color, "name": target_name}))

    return result

# Process {player:text} patterns
func _process_player_patterns(text: String, _context: Dictionary) -> String:
    var regex := RegEx.new()
    regex.compile("\\{player:([^}]+)\\}")

    var result := text
    for regex_match in regex.search_all(text):
        var full_match := regex_match.get_string(0)
        var content := regex_match.get_string(1)
        result = result.replace(full_match, content)

    return result

# Process {enemy:text} patterns
func _process_enemy_patterns(text: String, _context: Dictionary) -> String:
    var regex := RegEx.new()
    regex.compile("\\{enemy:([^}]+)\\}")

    var result := text
    for regex_match in regex.search_all(text):
        var full_match := regex_match.get_string(0)
        var content := regex_match.get_string(1)
        var colored := "[color=%s]%s[/color]" % [LogColors.ENEMY, content]
        result = result.replace(full_match, colored)

    return result

# Process {healing:amount} patterns
func _process_healing_patterns(text: String) -> String:
    var regex := RegEx.new()
    regex.compile("\\{healing:([^}]+)\\}")

    var result := text
    for regex_match in regex.search_all(text):
        var full_match := regex_match.get_string(0)
        var content := regex_match.get_string(1)
        var colored := "[color=%s]%s HP[/color]" % [LogColors.HEALING, content]
        result = result.replace(full_match, colored)

    return result

# Process {bonus:amount} patterns
func _process_bonus_patterns(text: String) -> String:
    var regex := RegEx.new()
    regex.compile("\\{bonus:([^}]+)\\}")

    var result := text
    for regex_match in regex.search_all(text):
        var full_match := regex_match.get_string(0)
        var content := regex_match.get_string(1)
        var colored := "[color=%s]%s[/color]" % [LogColors.BONUS, content]
        result = result.replace(full_match, colored)
    return result

# Process {damage:amount:type} patterns (type is optional, can also come from context)
func _process_damage_patterns(text: String, context: Dictionary = {}) -> String:
    var regex := RegEx.new()
    regex.compile("\\{damage:([^:}]+)(?::([^}]+))?\\}")

    var result := text
    for regex_match in regex.search_all(text):
        var full_match := regex_match.get_string(0)
        var amount := regex_match.get_string(1)
        var damage_type_str := regex_match.get_string(2) if regex_match.strings.size() > 2 else ""

        var color: String = LogColors.DEFAULT
        var damage_type_name: String = ""

        # First check if damage type is provided in context
        if context.has("damage_type"):
            var damage_type: DamageType.Type = context["damage_type"]
            color = DamageType.get_type_color(damage_type).to_html()
            damage_type_name = DamageType.get_type_name(damage_type)
        elif damage_type_str != "":
            # Fall back to parsing from string
            var damage_type := _string_to_damage_type(damage_type_str)
            if damage_type != -1:
                color = DamageType.get_type_color(damage_type).to_html()
                damage_type_name = DamageType.get_type_name(damage_type)

        var type_text := damage_type_name + " " if damage_type_name != "" else ""
        var colored := "[color=%s]%s %sdamage[/color]" % [color, amount, type_text]
        result = result.replace(full_match, colored)

    return result



# Process {effect:name} patterns
func _process_effect_patterns(text: String, context: Dictionary) -> String:
    var regex := RegEx.new()
    regex.compile("\\{effect:([^}]+)\\}")

    var result := text
    for regex_match in regex.search_all(text):
        var full_match := regex_match.get_string(0)
        var content := regex_match.get_string(1)
        # For now, use default color - could be enhanced to detect positive/negative effects
        var status_effect: StatusEffect = context.get("status_effect", null)
        var colored: String = ""
        if status_effect != null:
            colored = "[color=%s]%s[/color]" % [status_effect.get_effect_color(), content]
        else:
            colored = "[color=%s]%s[/color]" % [LogColors.DEFAULT, content]

        result = result.replace(full_match, colored)

    return result

# Process {effect_verb} patterns based on status_effect context
func _process_effect_verb_patterns(text: String, context: Dictionary) -> String:
    if not text.contains("{effect_verb}"):
        return text

    var status_effect: StatusEffect = context.get("status_effect", null)
    if status_effect == null:
        return text.replace("{effect_verb}", "affected")

    var is_positive: bool = status_effect.get_effect_type() == StatusEffect.EffectType.POSITIVE
    var effect_verb: String = "bestowed" if is_positive else "afflicted"
    return text.replace("{effect_verb}", effect_verb)

# Process {action} patterns that choose between player/non-player verb forms
func _process_action_patterns(text: String, context: Dictionary) -> String:
    var regex := RegEx.new()
    regex.compile("\\{action\\}")

    var result := text
    for regex_match in regex.search_all(text):
        var full_match := regex_match.get_string(0)

        # Get the action from context
        var action_array: Array = context.get("action", [])
        if action_array.is_empty() or action_array.size() < 2:
            # Fallback if no proper action array provided
            result = result.replace(full_match, "act")
            continue

        # Determine if target is the player
        var target: CombatEntity = context.get("target", null)
        var is_player: bool = (target != null and target == GameState.player)

        # Choose the appropriate verb form: [player_form, non_player_form]
        var chosen_action: String = action_array[0] if is_player else action_array[1]
        result = result.replace(full_match, chosen_action)

    return result

# Helper to convert damage type string to enum value
func _string_to_damage_type(damage_type_str: String) -> int:
    var type_str := damage_type_str.to_upper()
    match type_str:
        "PHYSICAL": return DamageType.Type.PHYSICAL
        "POISON": return DamageType.Type.POISON
        "FIRE": return DamageType.Type.FIRE
        "SHOCK": return DamageType.Type.SHOCK
        "ICE": return DamageType.Type.ICE
        "DARK": return DamageType.Type.DARK
        "HOLY": return DamageType.Type.HOLY
        _: return -1

# Internal function to add entries to history
func _add_to_history(rich_text: String) -> void:
    var entry := LogEntry.new(rich_text)
    log_history.push_front(entry)  # Add new entries to the beginning

    # Keep history within limits
    while log_history.size() > max_log_entries:
        log_history.pop_back()  # Remove oldest entries from the end

# Function to restore log history to a RichTextLabel
func restore_log_history(log_label: RichTextLabel) -> void:
    log_label.clear()
    for entry in log_history:
        log_label.append_text("%s\n" % [entry.rich_text])
    # No scrolling needed since newest entries are already at the top

# Function to clear log history (useful for new runs)
func clear_log_history() -> void:
    log_history.clear()

# Function to get log history for other uses
func get_log_history() -> Array[LogEntry]:
    return log_history

# === LEGACY CONVENIENCE METHODS ===
# These provide backwards compatibility while using the new system internally

func log_message(text: String) -> void:
    log_event(text)

# Helper function to get display name for any target
func _get_target_name(target: Object) -> String:
    if target == null:
        return "Unknown"
    elif target == GameState.player:
        return "you"
    elif target.has_method("get_name"):
        return target.call("get_name")
    elif target.has_method("get_display_name"):
        return target.call("get_display_name")
    else:
        return "Unknown"
