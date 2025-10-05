# screens/TitleScreen.gd
class_name TitleScreen extends Control
signal start_requested

@export var start_btn: Button
@export var quit_btn: Button

func _ready() -> void:
    start_btn.pressed.connect(func(): emit_signal("start_requested"))
    quit_btn.pressed.connect(get_tree().quit)
