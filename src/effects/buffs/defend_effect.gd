class_name DefendEffect extends StatBoostEffect

@export var defense_bonus: int = 50

func _init(defense_value: int = 50) -> void:
    defense_bonus = defense_value
    duration = 1  # Lasts for 1 turn (now works correctly with fixed combat flow)

func get_effect_id() -> String:
    return "defend"

const CANONICAL_NAME := "Defending"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Override to provide the actual defense bonus
func get_defense_bonus() -> int:
    return defense_bonus

func get_description() -> String:
    return "+%d%% damage reduction (defending)" % defense_bonus

func get_base_description() -> String:
    return "+%d%% damage reduction (defending)" % defense_bonus