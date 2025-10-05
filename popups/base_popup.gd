# popups/BasePopup.gd
class_name BasePopup extends Window

## Base class for all popups that provides consistent centering functionality

func _center_on_screen() -> void:
    """Centers the popup on the screen based on current size"""
    # Use call_deferred to ensure the popup is fully ready
    call_deferred("_do_center")

func _do_center() -> void:
    """Actually perform the centering calculation"""
    # Debug: Print current values
    print("Centering popup - Current size: ", size)
    print("Centering popup - Current position: ", position)

    # Try using the root viewport instead
    var main_viewport = get_tree().root
    if main_viewport:
        var screen_size = main_viewport.get_visible_rect().size
        print("Screen size: ", screen_size)

        var popup_size = size
        var new_position = Vector2i(
            (screen_size.x - popup_size.x) / 2,
            (screen_size.y - popup_size.y) / 2
        )
        print("Calculated new position: ", new_position)

        position = new_position
        print("Position after setting: ", position)
    else:
        print("No main viewport found!")

func _center_on_screen_after_frame() -> void:
    """Centers the popup after waiting one frame for layout to complete"""
    await get_tree().process_frame
    _center_on_screen()
