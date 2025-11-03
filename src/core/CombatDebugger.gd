class_name CombatDebugger
extends Node

# LogLevel enum for controlling debug output
enum LogLevel {
	NONE = 0,
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	DEBUG = 4,
	TRACE = 5
}

# Signal emitted when a message is logged
signal message_logged(message: String)

# Current logging level
var current_log_level: LogLevel = LogLevel.INFO

# Singleton instance
static var instance: CombatDebugger

func _ready() -> void:
	# Set up singleton instance
	if not instance:
		instance = self
	else:
		queue_free()

# Set the current log level
func set_log_level(level: LogLevel) -> void:
	current_log_level = level

# Log a message at the specified level
func log_message(message: String, level: LogLevel) -> void:
	if level <= current_log_level:
		message_logged.emit(message)

# Get a summary of the current combat state
func get_combat_state_summary(context: Dictionary) -> String:
	var summary := "=== Combat State Summary ===\n"

	# Turn and phase information
	summary += "Turn: %d\n" % context.get("current_turn", 1)
	summary += "Phase: %s\n" % context.get("current_phase", "UNKNOWN")

	# Player information
	var player: Dictionary = context.get("player", {})
	if player:
		summary += "Player HP: %d/%d\n" % [
			player.get("current_hp", 0),
			player.get("max_hp", 0)
		]

	# Enemy information
	var enemy: Dictionary = context.get("enemy", {})
	if enemy:
		summary += "Enemy HP: %d/%d\n" % [
			enemy.get("current_hp", 0),
			enemy.get("max_hp", 0)
		]

	return summary

# Trace status effect expiration
func trace_status_effect_expiration(effect: Dictionary, timing: EffectTiming.Type) -> void:
	var timing_name := str(timing)  # Use raw enum value instead of get_name
	var effect_name: String = effect.get("name", "Unknown Effect")
	var message := "[COMBAT DEBUG] Effect '%s' expired at %s" % [effect_name, timing_name]
	log_message(message, LogLevel.DEBUG)

# Get active effects summary for an entity
func get_active_effects_summary(entity: Dictionary) -> String:
	var summary := "Active Effects for %s:\n" % entity.get("name", "Unknown Entity")

	var effects: Array = entity.get("active_effects", [])
	if effects.is_empty():
		summary += "  No active effects\n"
	else:
		for effect: Dictionary in effects:
			var timing_value: int = effect.get("expire_timing", EffectTiming.Type.TURN_END)
			# Use raw enum value instead of get_name
			var timing_name := str(timing_value)
			summary += "  - %s (expires: %s, turns left: %d)\n" % [
				effect.get("name", "Unknown"),
				timing_name,
				effect.get("expire_after_turns", 0)
			]

	return summary

# Get effect expiration timeline
func get_effect_expiration_timeline(entity: Dictionary) -> Array:
	var timeline := []
	var effects: Array = entity.get("active_effects", [])

	for effect: Dictionary in effects:
		var timing_value: int = effect.get("expire_timing", EffectTiming.Type.TURN_END)
		# Use raw enum value instead of get_name
		var timing_name := str(timing_value)
		var expire_after_turns: int = effect.get("expire_after_turns", 0)
		var applied_turn: int = effect.get("applied_turn", 1)
		var effect_name: String = effect.get("name", "Unknown")

		# Calculate the actual turn when the effect expires
		var expiration_turn := applied_turn + expire_after_turns - 1

		var entry := "Turn %d %s: %s" % [expiration_turn, timing_name, effect_name]
		timeline.append(entry)

	# Sort timeline by turn number (basic sorting)
	timeline.sort()

	return timeline

# Trace status effect application
func trace_status_effect_applied(effect: Dictionary, target: Dictionary) -> void:
	var effect_name: String = effect.get("name", "Unknown Effect")
	var target_name: String = target.get("name", "Unknown Target")
	var message := "[COMBAT DEBUG] Effect '%s' applied to %s" % [effect_name, target_name]
	log_message(message, LogLevel.DEBUG)

# Format effect information
func format_effect_info(effect: Dictionary) -> String:
	var info := "Effect: %s\n" % effect.get("name", "Unknown")
	var timing_value: int = effect.get("expire_timing", EffectTiming.Type.TURN_END)
	# Use raw enum value instead of get_name
	var timing_name := str(timing_value)
	info += "expires: %s\n" % timing_name
	info += "turns left: %d\n" % effect.get("expire_after_turns", 0)
	return info