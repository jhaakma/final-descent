# StageProgressionManager.gd
# Autoload singleton to manage stage progression across room transitions
extends Node

signal all_stages_completed()  # Emitted when all stages have been beaten
signal stage_completed(stage_number: int)  # Emitted when a stage is completed

var stage_templates: Array[StageTemplateResource] = []
var _current_stage_instance: StageInstance = null
var _current_stage_index: int = 0
var _floors_in_current_stage: int = 0
var _all_stages_completed: bool = false

func initialize_stages(templates: Array[StageTemplateResource]) -> void:
    if not _current_stage_instance:
        """Initialize with stage templates - called once at run start"""
        stage_templates = templates
        _current_stage_index = 0
        _floors_in_current_stage = 0
        _current_stage_instance = null
        _initialize_current_stage()

func _initialize_current_stage() -> void:
    """Initialize stage plan if we don't have one yet"""
    if _current_stage_instance != null:
        print("Stage plan already exists, skipping initialization")
        return

    # Get current stage template
    if stage_templates.is_empty():
        push_error("No stage templates configured on StageProgressionManager")
        return

    var template: StageTemplateResource = stage_templates[_current_stage_index]

    # Generate stage instance
    var rng_seed := GameState.rng.seed
    var stage_number := _current_stage_index + 1
    _current_stage_instance = StageGenerator.generate(
        stage_number,
        template,
        rng_seed,
    )
    _floors_in_current_stage = 0

    print("Stage plan initialized: %d rooms planned" % _current_stage_instance.planned_rooms.size())

    # Debug: Print planned rooms
    for i in range(_current_stage_instance.planned_rooms.size()):
        var room := _current_stage_instance.planned_rooms[i]
        print("  Floor %d: %s (%s)" % [i + 1, room.title, RoomType.get_display_name(room.room_type)])

func get_current_room() -> RoomResource:
    """Get the current room for the current floor in the current stage"""
    if _all_stages_completed:
        return null

    if not _current_stage_instance:
        push_error("No stage instance available")
        return null

    if _floors_in_current_stage >= _current_stage_instance.planned_rooms.size():
        return null

    return _current_stage_instance.planned_rooms[_floors_in_current_stage]

func advance_floor() -> void:
    """Advance to the next floor in the current stage"""
    _floors_in_current_stage += 1

    if _floors_in_current_stage >= _current_stage_instance.planned_rooms.size():
        # Stage completed
        var completed_stage_number: int = _current_stage_index + 1
        emit_signal("stage_completed", completed_stage_number)
        _advance_to_next_stage()

func _advance_to_next_stage() -> void:
    """Advance to the next stage template"""
    _current_stage_index += 1
    if _current_stage_index >= stage_templates.size():
        # All stages completed - trigger victory condition
        _all_stages_completed = true
        emit_signal("all_stages_completed")
        return

    _current_stage_instance = null
    _floors_in_current_stage = 0
    _initialize_current_stage()

func get_stage_number() -> int:
    """Get the current stage number (1-indexed)"""
    return _current_stage_index + 1

func get_floor_in_stage() -> int:
    """Get the current floor number within the stage (1-indexed)"""
    return _floors_in_current_stage + 1

func get_total_floors_in_stage() -> int:
    """Get the total number of floors in the current stage"""
    if _current_stage_instance:
        return _current_stage_instance.template.floors
    return 0

func reset() -> void:
    """Reset stage progression - called when starting a new run"""
    _current_stage_index = 0
    _floors_in_current_stage = 0
    _current_stage_instance = null
    _all_stages_completed = false
    if not stage_templates.is_empty():
        _initialize_current_stage()

func are_all_stages_completed() -> bool:
    """Check if all stages have been completed (victory condition)"""
    return _all_stages_completed
