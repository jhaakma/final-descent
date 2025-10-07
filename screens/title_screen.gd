# screens/TitleScreen.gd
class_name TitleScreen extends Control
signal start_requested

@onready var start_btn: Button = %StartBtn
@onready var options_btn: Button = %OptionsBtn
@onready var quit_btn: Button = %QuitBtn

# Options popup scene
var options_popup_scene = preload("res://popups/OptionsPopup.tscn")
var current_options_popup = null

func _ready() -> void:
    start_btn.pressed.connect(func(): emit_signal("start_requested"))
    options_btn.pressed.connect(_on_options_pressed)
    quit_btn.pressed.connect(get_tree().quit)

func _on_options_pressed() -> void:
    if current_options_popup:
        return  # Prevent multiple instances

    # Create and show options popup
    current_options_popup = options_popup_scene.instantiate()
    current_options_popup.popup_closed.connect(_on_options_popup_closed)
    get_tree().current_scene.add_child(current_options_popup)

func _on_options_popup_closed() -> void:
    current_options_popup = null
