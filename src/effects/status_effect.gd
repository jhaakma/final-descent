class_name StatusEffect extends Resource

@export var effect_name: String = ""
var effect_type: EffectType = EffectType.NEUTRAL

enum EffectType {
    NEUTRAL,
    POSITIVE,
    NEGATIVE
}

static var EffectTypeMap := {
    EffectType.NEUTRAL: "white", # White
    EffectType.POSITIVE: "green", # Green
    EffectType.NEGATIVE: "red"  # Red
}

func _init(name: String = "")->void:
    if name.strip_edges() != "":
        effect_name = name

# Returns true if status effect was applied successfully
func apply_effect(_target: CombatEntity) -> bool:
    # Return a StatusEffectResult with effect results
    return true

# Get descriptive text for UI
func get_description() -> String:
    return effect_name
