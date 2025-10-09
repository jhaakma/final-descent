class_name CureStatusEffect extends StatusEffect

@export var status_to_cure: String

func _init():
    super._init("CureStatusEffect")
    effect_type = EffectType.POSITIVE

# Override apply_effect to implement cure logic
func apply_effect(target) -> bool:
    var target_entity := target as CombatEntity
    if target_entity:
        if target_entity.has_status_effect(status_to_cure):
            target_entity.remove_status_effect(status_to_cure)
            LogManager.log_status_effect_removed(target_entity, status_to_cure, "was cured")
            return true
        else:
            var target_name: String = "You are" if target_entity == GameState.player else "%s is" % target_entity.get_name()
            LogManager.log_message("%s not affected by %s." % [target_name, status_to_cure])
            return false
    else:
        return false

# Override get_description for better poison-specific formatting
func get_description() -> String:
    return "Cures the %s status effect." % status_to_cure