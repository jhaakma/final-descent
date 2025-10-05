class_name AttackBuff extends Buff

@export var attack_bonus: int = 3

func _init():
	super._init()
	name = "Blessing of Strength"
	description = "The shrine's blessing enhances your attack power."
	duration_turns = 8

func apply_effects() -> void:
	GameState.player.buff_attack_bonus += attack_bonus
	LogManager.log_success("Buff applied: %s (+%d ATK, %d turns)" % [name, attack_bonus, remaining_duration])

func remove_effects() -> void:
	GameState.player.buff_attack_bonus -= attack_bonus
	LogManager.log_warning("Buff expired: %s" % name)