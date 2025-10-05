class_name BalancedBuff extends Buff

@export var attack_bonus: int = 2
@export var defense_bonus: int = 1

func _init():
	super._init()
	name = "Blessing of Balance"
	description = "The shrine's blessing enhances both your offense and defense."
	duration_turns = 6

func apply_effects() -> void:
	GameState.player.buff_attack_bonus += attack_bonus
	GameState.player.buff_defense_bonus += defense_bonus
	LogManager.log_success("Buff applied: %s (+%d ATK, +%d DEF, %d turns)" % [name, attack_bonus, defense_bonus, remaining_duration])

func remove_effects() -> void:
	GameState.player.buff_attack_bonus -= attack_bonus
	GameState.player.buff_defense_bonus -= defense_bonus
	LogManager.log_warning("Buff expired: %s" % name)