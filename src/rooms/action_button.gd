class_name ActionButton extends Resource

@export var button_text: String = ""
@export var tooltip: String = ""

func _init(text: String = "", tooltip_text: String = ""):
    button_text = text
    tooltip = tooltip_text