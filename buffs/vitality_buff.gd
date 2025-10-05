class_name VitalityBuff extends Buff

@export var max_hp_bonus: int = 5

func _init():
    super._init()
    name = "Blessing of Vitality"
    description = "The shrine's blessing increases your maximum health."
    duration_turns = 12

func apply_effects() -> void:
    GameState.player.max_hp += max_hp_bonus
    GameState.player.hp += max_hp_bonus  # Also heal when gaining max HP
    LogManager.log_success("Buff applied: %s (+%d MAX HP, %d turns)" % [name, max_hp_bonus, remaining_duration])

func remove_effects() -> void:
    GameState.player.max_hp -= max_hp_bonus
    # Don't reduce current HP below the new max
    GameState.player.hp = min(GameState.player.hp, GameState.player.max_hp)
    LogManager.log_warning("Buff expired: %s" % name)
