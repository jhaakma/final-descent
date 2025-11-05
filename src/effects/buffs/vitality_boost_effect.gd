class_name VitalityBoostEffect extends StatBoostEffect

@export var max_hp_bonus: int = 5

func get_effect_id() -> String:
    return "vitality_boost"

const CANONICAL_NAME := "+MAX HP"

func get_effect_name() -> String:
    return CANONICAL_NAME

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_magnitude() -> int:
    return max_hp_bonus

# Override to provide the actual max HP bonus
func get_max_hp_bonus() -> int:
    return max_hp_bonus

func get_description() -> String:
    return "+%d MAX HP for %d turns" % [max_hp_bonus, expire_after_turns]

func get_description_with_instance(instance: EffectInstance) -> String:
    if instance:
        return "+%d MAX HP for %d turns" % [max_hp_bonus, instance.get_remaining_turns()]
    return get_description()

func get_base_description() -> String:
    return "+%d MAX HP for %d turns" % [max_hp_bonus, expire_after_turns]