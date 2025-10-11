class_name TooltipManager extends Control

## Manages custom tooltips with proper screen boundary handling
##
## This component provides smart tooltip positioning that prevents tooltips
## from being cut off at screen edges.

static var instance: TooltipManager
var current_tooltip: Control
var tooltip_offset := Vector2(10, 10)  # Offset from mouse position

func _ready() -> void:
    instance = self
    # Make sure this tooltip manager is on top
    z_index = 1000
    mouse_filter = Control.MOUSE_FILTER_IGNORE

static func get_instance() -> TooltipManager:
    if not instance:
        # Create instance if it doesn't exist
        var scene_tree := Engine.get_main_loop() as SceneTree
        if scene_tree and scene_tree.current_scene:
            instance = TooltipManager.new()
            scene_tree.current_scene.add_child(instance)
    return instance

## Show a tooltip at the mouse position with smart positioning
func show_tooltip(tooltip: Control) -> void:
    hide_tooltip()

    current_tooltip = tooltip
    add_child(tooltip)

    # Position tooltip near mouse with boundary checking
    _position_tooltip_smart()
    tooltip.show()

## Hide the current tooltip
func hide_tooltip() -> void:
    if current_tooltip:
        if current_tooltip.get_parent() == self:
            remove_child(current_tooltip)
        current_tooltip.queue_free()
        current_tooltip = null

## Position tooltip with smart boundary detection
func _position_tooltip_smart() -> void:
    if not current_tooltip:
        return

    var mouse_pos := get_global_mouse_position()
    var tooltip_size := current_tooltip.size
    var screen_size := get_viewport().get_visible_rect().size

    # Start with mouse position + offset
    var target_pos := mouse_pos + tooltip_offset

    # Check right boundary - if tooltip would go off right edge, show on left side of mouse
    if target_pos.x + tooltip_size.x > screen_size.x:
        target_pos.x = mouse_pos.x - tooltip_size.x - tooltip_offset.x

    # Check left boundary
    if target_pos.x < 0:
        target_pos.x = 0

    # Check bottom boundary - if tooltip would go off bottom, show above mouse
    if target_pos.y + tooltip_size.y > screen_size.y:
        target_pos.y = mouse_pos.y - tooltip_size.y - tooltip_offset.y

    # Check top boundary
    if target_pos.y < 0:
        target_pos.y = 0

    current_tooltip.global_position = target_pos

func _input(event: InputEvent) -> void:
    # Update tooltip position when mouse moves
    if current_tooltip and current_tooltip.visible and event is InputEventMouseMotion:
        _position_tooltip_smart()
