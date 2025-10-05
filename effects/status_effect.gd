class_name StatusEffect extends Resource

var effect_name: String = ""
var effect_color: EffectColor = EffectColor.NEUTRAL

enum EffectColor {
    NEUTRAL,
    POSITIVE,
    NEGATIVE
}

static var EffectColorMap = {
    EffectColor.NEUTRAL: "white", # White
    EffectColor.POSITIVE: "green", # Green
    EffectColor.NEGATIVE: "red"  # Red
}

func _init(name: String = ""):
    effect_name = name

func apply_effect(_target) -> StatusEffectResult:
    # Return a StatusEffectResult with effect results
    return StatusEffectResult.new(effect_name, "Base effect applied")

# Get descriptive text for UI
func get_description() -> String:
    return effect_name