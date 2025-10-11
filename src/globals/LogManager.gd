
extends Node
# Log color enum for different types of messages

class LogMetadata:

    func init(args: Dictionary) -> void:
        text = args.get("text", "")
        target = args.get("target", null)
        color = args.get("color", LogColor.DEFAULT)

    var text: String
    var target: CombatEntity
    var color: LogColor

enum LogColor {
    DEFAULT,
    DAMAGE_YOU,
    DAMAGE_THEM,
    HEALING,
    BUFF,
    COMBAT,
    SUCCESS,
    WARNING,
}

var LogColors: Dictionary[LogColor, String]= {
    LogColor.DEFAULT: "#ffffffff",
    LogColor.DAMAGE_YOU: "#ff0000ff",
    LogColor.DAMAGE_THEM: "#b47bffff",
    LogColor.HEALING: "#a1f7afff",
    LogColor.BUFF: "#79fbffff",
    LogColor.COMBAT: "#ff9900ff",
    LogColor.SUCCESS: "#00ff00ff",
    LogColor.WARNING: "#fffb00ff",
}

# Structure to store log entries
class LogEntry:
    var text: String
    var color: String

    func _init(log_text: String, log_color: String)->void:
        text = log_text
        color = log_color

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

## Utility function to replace {You}, {Your}, etc. in log strings
static func replace_name_patterns(text: String, target: CombatEntity) -> String:
    var replacements: Dictionary[String, String]
    var is_player := target == GameState.player
    if is_player:
        replacements = {
            "{You}": "You",
            "{you}": "you",
            "{Your}": "Your",
            "{your}": "your",
            "{You are}": "You are",
            "{you are}": "you are",
        }
    else:
        var target_name := target.get_name()
        replacements = {
            "{You}": "%s" % target_name,
            "{you}": "%s" % target_name,
            "{Your}": "%s's" % target_name,
            "{your}": "%s's" % target_name,
            "{You are}": "%s is" % target_name,
            "{you are}": "%s is" % target_name,
        }

    for pattern: String in replacements.keys():
        text = text.replace(pattern, replacements[pattern])
    return text

func log(args: Dictionary) -> void:
    var metadata := LogMetadata.new()
    metadata.init(args)
    var color_str := _get_color_str(metadata.color)
    var entry_text := metadata.text
    if metadata.target != null:
        entry_text = replace_name_patterns(entry_text, metadata.target)
    _add_to_history(entry_text, color_str)
    _update_all_displays()

# Logging convenience functions for different message types
func log_message(text: String, color_str: String = _get_color_str(LogColor.DEFAULT)) -> void:
    _add_to_history(text, color_str)
    _update_all_displays()


func log_damage(text: String, you: bool = true) -> void:
    if you:
        _add_to_history(text, _get_color_str(LogColor.DAMAGE_YOU))
    else:
        _add_to_history(text, _get_color_str(LogColor.DAMAGE_THEM))
    _update_all_displays()

func log_status(text: String, target: CombatEntity, positive: bool) -> void:
    var replaced_text := replace_name_patterns(text, target)
    if positive:
        _add_to_history(replaced_text, _get_color_str(LogColor.BUFF))
    else:
        _add_to_history(replaced_text, _get_color_str(LogColor.WARNING))
    _update_all_displays()

func log_healing(text: String) -> void:
    _add_to_history(text, _get_color_str(LogColor.HEALING))
    _update_all_displays()

func log_buff(text: String) -> void:
    _add_to_history(text, _get_color_str(LogColor.BUFF))
    _update_all_displays()

func log_combat(text: String) -> void:
    _add_to_history(text, _get_color_str(LogColor.COMBAT))
    _update_all_displays()

func log_success(text: String) -> void:
    _add_to_history(text, _get_color_str(LogColor.SUCCESS))
    _update_all_displays()

func log_warning(text: String) -> void:
    _add_to_history(text, _get_color_str(LogColor.WARNING))
    _update_all_displays()

func _get_color_str(color: LogColor) -> String:
    return LogColors.get(color, "#ffffffff")

# Internal function to add entries to history
func _add_to_history(text: String, color_str: String) -> void:
    var entry := LogEntry.new(text, color_str)
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

# Enhanced combat logging methods with target context
func log_attack(attacker: CombatEntity, target: CombatEntity, damage: int, weapon_name: String = "") -> void:
    var attacker_name := _get_target_name(attacker)
    var target_name := _get_target_name(target)

    var message: String
    if weapon_name != "":
        if attacker == GameState.player:
            message = "%s strike %s with %s for %d damage!" % [attacker_name.capitalize(), target_name, weapon_name, damage]
        else:
            message = "%s strikes %s with %s for %d damage!" % [attacker_name.capitalize(), target_name, weapon_name, damage]
    else:
        if attacker == GameState.player:
            message = "%s strike %s for %d damage!" % [attacker_name.capitalize(), target_name, damage]
        else:
            message = "%s attacks %s for %d damage!" % [attacker_name.capitalize(), target_name, damage]

    log_damage(message, target == GameState.player)

func log_special_attack(attacker: CombatEntity, target: CombatEntity, attack_name: String, damage: int, additional_effects: String = "") -> void:
    var attacker_name := _get_target_name(attacker)
    var target_name := _get_target_name(target)

    var message := "%s uses %s on %s for %d damage!" % [attacker_name.capitalize(), attack_name, target_name, damage]
    if additional_effects != "":
        message += " " + additional_effects

    log_damage(message, target == GameState.player)

func log_defend(defender: CombatEntity) -> void:
    var defender_name := _get_target_name(defender)
    var message: String
    if defender == GameState.player:
        message = "You brace yourself for defense."
    else:
        message = "%s braces for defense!" % defender_name.capitalize()
    log_combat(message)

func log_status_condition_applied(target: CombatEntity, condition: StatusCondition, duration: int = 0) -> void:
    var message: String

    var positive := condition.status_effect.get_effect_type() == StatusEffect.EffectType.POSITIVE
    var effect_verb := "bestowed" if positive else "afflicted"

    var effect_name:= condition.get_log_name()

    if target == GameState.player:
        if duration > 0:
            message = "You are %s with %s (%d turns)!" % [effect_verb, effect_name, duration]
        else:
            message = "You are %s with %s!" % [effect_verb, effect_name]
    else:
        var target_name := _get_target_name(target)
        if duration > 0:
            message = "%s is %s with %s (%d turns)!" % [target_name.capitalize(), effect_verb, effect_name, duration]
        else:
            message = "%s is %s with %s!" % [target_name.capitalize(), effect_verb, effect_name]

    if positive:
        log_buff(message)
    else:
        log_warning(message)


func log_status_effect_damage(target: CombatEntity, effect_name: String, damage: int) -> void:
    var message: String

    if target == GameState.player:
        message = "You take %d damage from %s!" % [damage, effect_name]
    else:
        var target_name := _get_target_name(target)
        message = "%s takes %d damage from %s!" % [target_name.capitalize(), damage, effect_name]

    log_damage(message, target == GameState.player)

func log_status_effect_healing(target: CombatEntity, effect_name: String, healing: int) -> void:
    var message: String

    if target == GameState.player:
        message = "You heal %d HP from %s!" % [healing, effect_name]
    else:
        var target_name := _get_target_name(target)
        message = "%s heals %d HP from %s!" % [target_name.capitalize(), healing, effect_name]

    log_healing(message)

func log_status_effect_removed(target: CombatEntity, effect_name: String, reason: String = "expired") -> void:
    var target_name := _get_target_name(target)
    var message: String
    if target == GameState.player:
        message = "Your %s %s." % [effect_name, reason]
    else:
        message = "%s's %s %s." % [target_name.capitalize(), effect_name, reason]
    log_warning(message)

func log_flee_attempt(attacker: CombatEntity, success: bool) -> void:
    var message: String

    if success:
        if attacker == GameState.player:
            message = "You flee successfully!"
        else:
            var attacker_name := _get_target_name(attacker)
            message = "%s flees from combat!" % attacker_name.capitalize()
        log_success(message)
    else:
        if attacker == GameState.player:
            message = "You fail to flee!"
        else:
            var attacker_name := _get_target_name(attacker)
            message = "%s tries to flee but fails!" % attacker_name.capitalize()
        log_warning(message)
