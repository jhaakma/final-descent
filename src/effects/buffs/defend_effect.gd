class_name DefendEffect extends StatBoostEffect

@export var defense_bonus: int = 50

func _init(defense_value: int = 50) -> void:
    defense_bonus = defense_value
    expire_timing = EffectTiming.Type.TURN_START
    expire_after_turns = 1  # Lasts through current turn and expires on next player TURN_START

func get_effect_id() -> String:
    return "defend"

const CANONICAL_NAME := "Defending"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_magnitude() -> int:
    return defense_bonus

# Override to provide the actual defense bonus
func get_defense_bonus() -> int:
    return defense_bonus

func get_description() -> String:
    return "+%d DEF for %d turns (defending)" % [defense_bonus, get_remaining_turns()]

# Called when the effect is first applied to an entity
func on_applied(_target: CombatEntity) -> void:
    # Set applied_turn to 1 since defend is typically applied during turn 1
    applied_turn = 1
