class_name CureStatusEffect extends StatusEffect

@export var status_to_cure: StatusEffect = null

func get_effect_id() -> String:
    return "cure_%s" % status_to_cure.get_effect_id()

func get_effect_name() -> String:
    return "Cure %s" % status_to_cure.get_effect_name()

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Override apply_effect to implement cure logic
func apply_effect(target: CombatEntity) -> bool:
    var target_entity := target as CombatEntity
    if target_entity:
        if target_entity.has_status_effect(status_to_cure.get_effect_id()):
            target_entity.remove_status_effect(status_to_cure)
            return true
        else:
            var target_name: String = "You are" if target_entity == GameState.player else "%s is" % target_entity.get_name()
            LogManager.log_warning("%s not affected by %s" % [target_name, status_to_cure.get_effect_name()])
            return false
    else:
        return false

# Override get_description for better poison-specific formatting
func get_description() -> String:
    return "Cures the %s status effect." % status_to_cure.get_effect_name()
