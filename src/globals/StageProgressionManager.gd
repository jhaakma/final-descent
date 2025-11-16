# StageProgressionManager.gd
# Autoload singleton to manage stage progression across room transitions
extends Node

var stage_templates: Array[StageTemplateResource] = []
var current_stage_instance: StageInstance = null
var current_stage_index: int = 0
var floors_in_current_stage: int = 0

signal stage_completed
signal stage_initialized(stage_instance: StageInstance)

func initialize_stages(templates: Array[StageTemplateResource]) -> void:
    """Initialize with stage templates - called once at run start"""
    stage_templates = templates
    current_stage_index = 0
    floors_in_current_stage = 0
    current_stage_instance = null
    _initialize_current_stage()

func _initialize_current_stage() -> void:
    """Initialize stage plan if we don't have one yet"""
    if current_stage_instance != null:
        print("Stage plan already exists, skipping initialization")
        return

    # Get current stage template
    if stage_templates.is_empty():
        push_error("No stage templates configured on StageProgressionManager")
        return

    var template: StageTemplateResource = stage_templates[current_stage_index]

    # Generate stage instance
    var rng_seed := GameState.rng.seed
    var stage_number := current_stage_index + 1
    current_stage_instance = StageGenerator.generate(
        stage_number,
        template,
        rng_seed,
    )
    floors_in_current_stage = 0

    print("Stage plan initialized: %d rooms planned" % current_stage_instance.planned_rooms.size())

    # Debug: Print planned rooms
    for i in range(current_stage_instance.planned_rooms.size()):
        var room := current_stage_instance.planned_rooms[i]
        print("  Floor %d: %s (%s)" % [i + 1, room.title, RoomType.get_display_name(room.room_type)])

    emit_signal("stage_initialized", current_stage_instance)

func get_current_room() -> RoomResource:
    """Get the current room for the current floor in the current stage"""
    if not current_stage_instance:
        push_error("No stage instance available")
        return null

    if floors_in_current_stage >= current_stage_instance.planned_rooms.size():
        return null

    return current_stage_instance.planned_rooms[floors_in_current_stage]

func advance_floor() -> void:
    """Advance to the next floor in the current stage"""
    floors_in_current_stage += 1

    if floors_in_current_stage >= current_stage_instance.planned_rooms.size():
        # Stage completed
        _advance_to_next_stage()

func _advance_to_next_stage() -> void:
    """Advance to the next stage template"""
    emit_signal("stage_completed")

    current_stage_index += 1
    if current_stage_index >= stage_templates.size():
        # Loop back to first stage if we run out
        current_stage_index = 0

    current_stage_instance = null
    floors_in_current_stage = 0
    _initialize_current_stage()

func is_stage_complete() -> bool:
    """Check if the current stage is complete"""
    if not current_stage_instance:
        return false
    return floors_in_current_stage >= current_stage_instance.planned_rooms.size()

func get_stage_number() -> int:
    """Get the current stage number (1-indexed)"""
    return current_stage_index + 1

func get_floor_in_stage() -> int:
    """Get the current floor number within the stage (1-indexed)"""
    return floors_in_current_stage + 1

func get_total_floors_in_stage() -> int:
    """Get the total number of floors in the current stage"""
    if current_stage_instance:
        return current_stage_instance.template.floors
    return 0

func reset() -> void:
    """Reset stage progression - called when starting a new run"""
    current_stage_index = 0
    floors_in_current_stage = 0
    current_stage_instance = null
    if not stage_templates.is_empty():
        _initialize_current_stage()
