class_name DefenseBuff extends Buff

@export var defense_bonus: int = 2

func _init():
	super._init()
	name = "Blessing of Protection"
	description = "The shrine's blessing provides divine protection."
	duration_turns = 10

func apply_effects() -> void:
	GameState.player.buff_defense_bonus += defense_bonus
	LogManager.log_success("Buff applied: %s (+%d DEF, %d turns)" % [name, defense_bonus, remaining_duration])

func remove_effects() -> void:
	GameState.player.buff_defense_bonus -= defense_bonus
	LogManager.log_warning("Buff expired: %s" % name)