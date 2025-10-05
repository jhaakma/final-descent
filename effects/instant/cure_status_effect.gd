class_name CureStatusEffect extends StatusEffect

@export var status_to_cure: String

func _init():
    super._init("CureStatusEffect")
    effect_color = EffectColor.POSITIVE

# Override apply_effect to implement poison damage logic
func apply_effect(target) -> StatusEffectResult:
    if target.has_status_effect(status_to_cure):
        target.remove_status_effect(status_to_cure)
        LogManager.log_success("Cured %s!" % status_to_cure)
        return StatusEffectResult.new(
            effect_name,
            "Cured %s!" % status_to_cure
        )
    else:
        return StatusEffectResult.new(
            effect_name,
            "No effect. Target is not affected by %s." % status_to_cure
        )

# Override get_description for better poison-specific formatting
func get_description() -> String:
    return "Cures the %s status effect." % status_to_cure