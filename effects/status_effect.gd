class_name StatusEffect extends Resource

var effect_name: String = ""
var effect_type: EffectType = EffectType.NEUTRAL

enum EffectType {
    NEUTRAL,
    POSITIVE,
    NEGATIVE
}

static var EffectTypeMap = {
    EffectType.NEUTRAL: "white", # White
    EffectType.POSITIVE: "green", # Green
    EffectType.NEGATIVE: "red"  # Red
}

func _init(name: String = ""):
    effect_name = name

func apply_effect(_target) -> StatusEffectResult:
    # Return a StatusEffectResult with effect results
    return StatusEffectResult.new(effect_name, "Base effect applied")

# Get descriptive text for UI
func get_description() -> String:
    return effect_name
