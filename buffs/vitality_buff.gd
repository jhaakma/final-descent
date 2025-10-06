class_name VitalityBuff extends Buff

@export var max_hp_bonus: int = 5

func _init():
    super._init()
    name = "Blessing of Vitality"
    description = "The shrine's blessing increases your maximum health."
    duration_turns = 12

func apply_effects() -> void:
    # Increase max HP and heal by the bonus amount
    var new_max_hp = GameState.player.get_max_hp() + max_hp_bonus
    GameState.player.set_max_hp(new_max_hp)
    # Heal the player by the max HP bonus amount
    GameState.player.heal(max_hp_bonus)
    LogManager.log_success("Buff applied: %s (+%d MAX HP, %d turns)" % [name, max_hp_bonus, remaining_duration])

func remove_effects() -> void:
    var new_max_hp = GameState.player.get_max_hp() - max_hp_bonus
    GameState.player.set_max_hp(new_max_hp)
    # The HealthComponent automatically clamps current HP when max HP is reduced
    LogManager.log_warning("Buff expired: %s" % name)
