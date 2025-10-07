# popups/options_popup.gd
class_name OptionsPopup extends BasePopup

# Signals
signal popup_closed()

# UI Components
@onready var title_label: Label = %TitleLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var back_btn: Button = %BackBtn
@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog

# Components following composition pattern
var options_handler: OptionsHandler

# Button references for management
var reset_high_score_btn: Button

func _ready() -> void:
    # Initialize components
    options_handler = OptionsHandler.new()
    options_handler.option_executed.connect(_on_option_executed)

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

    # Add Reset High Score option
    reset_high_score_btn = Button.new()
    reset_high_score_btn.text = "Reset High Score"
    reset_high_score_btn.pressed.connect(_on_reset_high_score_pressed)
    options_container.add_child(reset_high_score_btn)

    # Future options can be added here

func _on_reset_high_score_pressed() -> void:
    # Show confirmation dialog
    var stats = options_handler.get_high_score_info()
    var message = "Are you sure you want to reset your high scores?\n\n"
    message += "Current Records:\n"
    message += "Best Floor: %d\n" % stats.best_floor
    message += "Best Gold: %d\n" % stats.best_gold
    message += "Total Runs: %d\n\n" % stats.total_runs
    message += "This action cannot be undone!"

    confirmation_dialog.dialog_text = message
    confirmation_dialog.popup_centered()

    # Connect the confirmation signal if not already connected
    if not confirmation_dialog.confirmed.is_connected(_on_reset_confirmed):
        confirmation_dialog.confirmed.connect(_on_reset_confirmed)

func _on_reset_confirmed() -> void:
    options_handler.reset_high_score()

func _on_option_executed(_option_name: String, _success: bool, message: String) -> void:
    # Show result message to user
    var result_dialog = AcceptDialog.new()
    result_dialog.title = "Success"
    result_dialog.dialog_text = message
    add_child(result_dialog)
    result_dialog.popup_centered()

    # Clean up the dialog after it's closed
    result_dialog.confirmed.connect(func(): result_dialog.queue_free())

func _on_back_pressed() -> void:
    emit_signal("popup_closed")
    queue_free()

# Clean up when popup is removed
func _exit_tree() -> void:
    # OptionsHandler extends RefCounted and will be automatically cleaned up
    # when the popup is destroyed, so no manual cleanup needed
    pass
