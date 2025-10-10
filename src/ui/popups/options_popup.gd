# popups/options_popup.gd
class_name OptionsPopup extends BasePopup

# Signals
signal popup_closed()

@export var options: Array[Option] = []

# UI Components
@onready var title_label: Label = %TitleLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var back_btn: Button = %BackBtn
@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog

# Button references for management
var reset_high_score_btn: Button

func _ready() -> void:
    # Connect back button
    back_btn.pressed.connect(_on_back_pressed)

    # Setup the options UI
    _setup_options_ui()

    # Center the popup on screen
    _center_on_screen_after_frame()

func _setup_options_ui() -> void:
    # Clear any existing options
    for child in options_container.get_children():
        child.queue_free()

    for option: Option in options:
        print("Adding option: %s" % option.get_display_name())
        var btn := Button.new()
        btn.text = option.get_display_name()
        options_container.add_child(btn)
        btn.pressed.connect(func()->void: on_option_selected(option))

static func get_scene() -> PackedScene:
    return preload("uid://bvqlqf7qkx2wg") as PackedScene

func on_option_selected(option: Option) -> void:
    print("Option selected: %s" % option.get_display_name())
    # Show confirmation dialog
    confirmation_dialog.dialog_text = option.get_confirmation_message()
    confirmation_dialog.popup_centered()
    confirmation_dialog.confirmed.connect(func()->void:
        #wait frame for dialog to close
        await get_tree().process_frame
        print("Executing option: %s" % option.get_display_name())
        option.execute()
        var result_dialog := AcceptDialog.new()
        result_dialog.title = "Success"
        result_dialog.dialog_text = option.get_executed_message()
        add_child(result_dialog)
        result_dialog.popup_centered()
        result_dialog.confirmed.connect(func()->void: result_dialog.queue_free())
    )


func _on_option_executed(_success: bool, message: String) -> void:
    # Show result message to user
    var result_dialog := AcceptDialog.new()
    result_dialog.title = "Success" if _success else "Error"
    result_dialog.dialog_text = message
    add_child(result_dialog)
    result_dialog.popup_centered()

    # Clean up the dialog after it's closed
    result_dialog.confirmed.connect(func()->void: result_dialog.queue_free())

func _on_back_pressed() -> void:
    emit_signal("popup_closed")
    queue_free()

# Clean up when popup is removed
func _exit_tree() -> void:
    # OptionsHandler extends RefCounted and will be automatically cleaned up
    # when the popup is destroyed, so no manual cleanup needed
    pass
