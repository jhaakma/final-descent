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
    EQUIPMENT = "#ff8844",
    COMBAT = "#88ff88",
    SUCCESS = "#ffff44",
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

func log_poison(text: String) -> void:
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
    log_history.append(entry)

    # Keep history within limits
    while log_history.size() > max_log_entries:
        log_history.pop_front()

# Function to restore log history to a RichTextLabel
# Function to restore log history to a RichTextLabel
func restore_log_history(log_label: RichTextLabel) -> void:
    log_label.clear()
    for entry in log_history:
        log_label.append_text("[color=%s]%s[/color]\n" % [entry.color, entry.text])
    # Use a more robust scrolling approach
    _ensure_scroll_to_bottom(log_label)

# Helper function to ensure scrolling to bottom works reliably
func _ensure_scroll_to_bottom(log_label: RichTextLabel) -> void:
    # Use call_deferred with a lambda/callable to wait for rendering
    log_label.call_deferred("scroll_to_line", 999999)  # Scroll to a very large line number to ensure bottom
    # Also try the proper approach after a frame
    call_deferred("_scroll_after_frame", log_label)

# This ensures we scroll after content is fully processed
func _scroll_after_frame(log_label: RichTextLabel) -> void:
    var line_count = log_label.get_line_count()
    if line_count > 0:
        log_label.scroll_to_line(line_count - 1)

# Function to clear log history (useful for new runs)
func clear_log_history() -> void:
    log_history.clear()

# Function to get log history for other uses
func get_log_history() -> Array[LogEntry]:
    return log_history
