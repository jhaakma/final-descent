extends Node
# Log color enum for different types of messages


enum LogColor {
    DEFAULT,
    DAMAGE,
    HEALING,
    POISON,
    EQUIPMENT,
    COMBAT,
    SUCCESS,
    WARNING,
}

var LogColors = {
    DEFAULT = "#ff4444",
    DAMAGE = "#44ff44",
    HEALING = "#aa44ff",
    POISON = "#4488ff",
    EQUIPMENT = "#4682b4",
    COMBAT = "#ff8844",
    SUCCESS = "#88ff88", #light green
    WARNING = "#ffffff",
}

# Structure to store log entries
class LogEntry:
    var text: String
    var color: String

    func _init(log_text: String, log_color: String):
        text = log_text
        color = log_color

# Store log history to persist between rooms
var log_history: Array[LogEntry] = []
var max_log_entries: int = 100  # Limit log entries to prevent memory issues

signal log_pushed(text: String, color: String)

# Logging convenience functions for different message types
func log_message(text: String, color: LogColor = LogColor.DEFAULT) -> void:
    var color_str = LogColors.get(color, LogColors.DEFAULT)
    _add_to_history(text, color_str)
    emit_signal("log_pushed", text, color_str)

# Backward compatibility - this maintains the old single-parameter interface
func push_log(text: String) -> void:
    _add_to_history(text, LogColors.DEFAULT)
    emit_signal("log_pushed", text, LogColors.DEFAULT)

func log_damage(text: String) -> void:
    _add_to_history(text, LogColors.DAMAGE)
    emit_signal("log_pushed", text, LogColors.DAMAGE)

func log_healing(text: String) -> void:
    _add_to_history(text, LogColors.HEALING)
    emit_signal("log_pushed", text, LogColors.HEALING)

func log_inflict_status(text: String) -> void:
    _add_to_history(text, LogColors.POISON)
    emit_signal("log_pushed", text, LogColors.POISON)

func log_equipment(text: String) -> void:
    _add_to_history(text, LogColors.EQUIPMENT)
    emit_signal("log_pushed", text, LogColors.EQUIPMENT)

func log_combat(text: String) -> void:
    _add_to_history(text, LogColors.COMBAT)
    emit_signal("log_pushed", text, LogColors.COMBAT)

func log_success(text: String) -> void:
    _add_to_history(text, LogColors.SUCCESS)
    emit_signal("log_pushed", text, LogColors.SUCCESS)

func log_warning(text: String) -> void:
    _add_to_history(text, LogColors.WARNING)
    emit_signal("log_pushed", text, LogColors.WARNING)

# Internal function to add entries to history
func _add_to_history(text: String, color: String) -> void:
    var entry = LogEntry.new(text, color)
    log_history.push_front(entry)  # Add new entries to the beginning

    # Keep history within limits
    while log_history.size() > max_log_entries:
        log_history.pop_back()  # Remove oldest entries from the end

# Function to restore log history to a RichTextLabel
# Function to restore log history to a RichTextLabel
func restore_log_history(log_label: RichTextLabel) -> void:
    log_label.clear()
    for entry in log_history:
        log_label.append_text("[color=%s]%s[/color]\n" % [entry.color, entry.text])
    # No scrolling needed since newest entries are already at the top

# Function to clear log history (useful for new runs)
func clear_log_history() -> void:
    log_history.clear()

# Function to get log history for other uses
func get_log_history() -> Array[LogEntry]:
    return log_history

# === ENHANCED COMBAT LOGGING WITH TARGET CONTEXT ===

# Helper function to get display name for any target
func _get_target_name(target) -> String:
    if target == null:
        return "Unknown"
    elif target == GameState.player:
        return "you"
    elif target.has_method("get_name"):
        return target.get_name()
    elif target.has_method("get_display_name"):
        return target.get_display_name()
    else:
        return "Unknown"

# Enhanced combat logging methods with target context
func log_attack(attacker, target, damage: int, weapon_name: String = "") -> void:
    var attacker_name = _get_target_name(attacker)
    var target_name = _get_target_name(target)

    var message: String
    if weapon_name != "":
        if attacker == GameState.player:
            message = "%s strike %s with %s for %d damage." % [attacker_name.capitalize(), target_name, weapon_name, damage]
        else:
            message = "%s strikes %s with %s for %d damage!" % [attacker_name.capitalize(), target_name, weapon_name, damage]
    else:
        if attacker == GameState.player:
            message = "%s strike %s for %d damage." % [attacker_name.capitalize(), target_name, damage]
        else:
            message = "%s attacks %s for %d damage!" % [attacker_name.capitalize(), target_name, damage]

    log_combat(message)

func log_special_attack(attacker, target, attack_name: String, damage: int, additional_effects: String = "") -> void:
    var attacker_name = _get_target_name(attacker)
    var target_name = _get_target_name(target)

    var message = "%s uses %s on %s for %d damage!" % [attacker_name.capitalize(), attack_name, target_name, damage]
    if additional_effects != "":
        message += " " + additional_effects

    log_combat(message)

func log_defend(defender) -> void:
    var defender_name = _get_target_name(defender)
    var message: String
    if defender == GameState.player:
        message = "You brace yourself for defense."
    else:
        message = "%s braces for defense!" % defender_name.capitalize()
    log_combat(message)

func log_status_effect_applied(target, effect_name: String, duration: int = 0) -> void:
    var message: String

    if target == GameState.player:
        if duration > 0:
            message = "You are afflicted with %s (%d turns)!" % [effect_name, duration]
        else:
            message = "You are afflicted with %s!" % [effect_name]
    else:
        var target_name = _get_target_name(target)
        if duration > 0:
            message = "%s is afflicted with %s (%d turns)!" % [target_name.capitalize(), effect_name, duration]
        else:
            message = "%s is afflicted with %s!" % [target_name.capitalize(), effect_name]

    log_combat(message)

func log_status_effect_damage(target, effect_name: String, damage: int) -> void:
    var message: String

    if target == GameState.player:
        message = "You take %d damage from %s!" % [damage, effect_name]
    else:
        var target_name = _get_target_name(target)
        message = "%s takes %d damage from %s!" % [target_name.capitalize(), damage, effect_name]

    log_inflict_status(message)

func log_status_effect_healing(target, effect_name: String, healing: int) -> void:
    var message: String

    if target == GameState.player:
        message = "You heal %d HP from %s!" % [healing, effect_name]
    else:
        var target_name = _get_target_name(target)
        message = "%s heals %d HP from %s!" % [target_name.capitalize(), healing, effect_name]

    log_healing(message)

func log_status_effect_removed(target, effect_name: String, reason: String = "expired") -> void:
    var target_name = _get_target_name(target)
    var message: String

    if target == GameState.player:
        message = "Your %s effect %s." % [effect_name, reason]
    else:
        message = "%s's %s effect %s." % [target_name.capitalize(), effect_name, reason]

    log_warning(message)

func log_flee_attempt(attacker, success: bool) -> void:
    var message: String

    if success:
        if attacker == GameState.player:
            message = "You flee successfully!"
        else:
            var attacker_name = _get_target_name(attacker)
            message = "%s flees from combat!" % attacker_name.capitalize()
        log_success(message)
    else:
        if attacker == GameState.player:
            message = "You fail to flee!"
        else:
            var attacker_name = _get_target_name(attacker)
            message = "%s tries to flee but fails!" % attacker_name.capitalize()
        log_warning(message)
