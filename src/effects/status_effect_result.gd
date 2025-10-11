class_name StatusEffectResult extends Resource

@export var effect_id: String = ""
@export var message: String = ""

func _init(_effect_id: String = "", _message: String = "") -> void:
    effect_id = _effect_id
    message = _message
