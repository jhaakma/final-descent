

class_name StatusEffect extends Resource

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

func get_effect_id() -> String:
    return get_class()

func get_effect_name() -> String:
    print_debug("get_effect_name() not implemented in subclass")
    return "Effect Name"

func create() -> StatusEffect:
    var effect_copy: StatusEffect = duplicate()
    return effect_copy

func get_effect_type() -> EffectType:
    return EffectType.NEUTRAL

func can_apply(_target: CombatEntity) -> bool:
    return true

# Returns true if status effect was applied successfully
func apply_effect(_target: CombatEntity) -> bool:
    # Return a StatusEffectResult with effect results
    return true

func get_effect_color() -> String:
    return EffectTypeMap.get(get_effect_type(), "white")

func get_description() -> String:
    print_debug("get_description() not implemented in subclass")
    return "Generic Status Effect"
