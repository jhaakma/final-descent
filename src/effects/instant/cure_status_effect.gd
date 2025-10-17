class_name CureStatusEffect extends StatusEffect

@export var condition_to_cure: String

func get_effect_id() -> String:
    if condition_to_cure:
        return "cure_%s" % condition_to_cure.to_lower()
    return "cure_unknown"

func get_effect_name() -> String:
    if condition_to_cure:
        return "Cure %s" % condition_to_cure
    return "Cure Unknown"

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Override apply_effect to implement cure logic
func apply_effect(target: CombatEntity) -> bool:
    var target_entity := target as CombatEntity
    if not target_entity or not condition_to_cure:
        return false

    # Check if the target has the specific condition by name
    if target_entity.has_status_condition(condition_to_cure):
        return target_entity.remove_status_condition(condition_to_cure)
    else:
        var target_name: String = "You are" if target_entity == GameState.player else "%s is" % target_entity.get_name()
        LogManager.log_event("%s not affected by %s" % [target_name, condition_to_cure])
        return false

# Override get_description for better condition-specific formatting
func get_description() -> String:
    if condition_to_cure:
        return "Cures the %s condition." % condition_to_cure
    return "Cures an unknown condition."
