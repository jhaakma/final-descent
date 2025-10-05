class_name CureStatusEffect extends StatusEffect

@export var status_to_cure: String

func _init():
    super._init("CureStatusEffect")
    effect_type = EffectType.POSITIVE

# Override apply_effect to implement cure logic
func apply_effect(target) -> StatusEffectResult:
    if target.has_status_effect(status_to_cure):
        target.remove_status_effect(status_to_cure)
        LogManager.log_status_effect_removed(target, status_to_cure, "was cured")
        return StatusEffectResult.new(
            effect_name,
            ""  # Message handled by LogManager
        )
    else:
        var target_name = "You are" if target == GameState.player else "%s is" % target.get_name()
        LogManager.log_message("%s not affected by %s." % [target_name, status_to_cure])
        return StatusEffectResult.new(
            effect_name,
            ""  # Message handled by LogManager
        )

# Override get_description for better poison-specific formatting
func get_description() -> String:
    return "Cures the %s status effect." % status_to_cure