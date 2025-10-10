# popups/ConfirmationPopup.gd
class_name ConfirmationPopup extends BasePopup

signal confirmed()
signal cancelled()

@onready var message_label: Label = %MessageLabel
@onready var yes_btn: Button = %YesBtn
@onready var no_btn: Button = %NoBtn

func _ready() -> void:
    # Connect button signals
    yes_btn.pressed.connect(_on_yes_pressed)
    no_btn.pressed.connect(_on_no_pressed)

    # Center the popup on screen
    _center_on_screen()

func show_confirmation(message: String) -> void:
    """Show the confirmation dialog with a custom message"""
    message_label.text = message
    show()

func _on_yes_pressed() -> void:
    emit_signal("confirmed")
    queue_free()

func _on_no_pressed() -> void:
    emit_signal("cancelled")
    queue_free()