class_name InlineContentBase extends Control

## Base class for all inline content that can be displayed in the room container
## This replaces the popup system with inline content that loads directly into the room

signal content_resolved()  # Emitted when the content interaction is complete
signal content_closed()    # Emitted when the content should be closed/hidden

var room_screen: RoomScreen = null

func initialize(target_room_screen: RoomScreen) -> void:
    """Initialize the inline content with a reference to the room screen"""
    room_screen = target_room_screen

func show_content() -> void:
    """Called when this content should be displayed"""
    visible = true

func hide_content() -> void:
    """Called when this content should be hidden"""
    visible = false

func cleanup() -> void:
    """Called when this content is being removed/destroyed"""
    if room_screen:
        room_screen = null

func _exit_tree() -> void:
    cleanup()