class_name StatusEffectResult extends Resource

@export var effect_name: String = ""
@export var message: String = ""

func _init(p_effect_name: String = "", p_message: String = ""):
    effect_name = p_effect_name
    message = p_message
