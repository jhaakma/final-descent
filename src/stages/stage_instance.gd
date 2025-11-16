## stage_instance.gd
## Runtime representation of a generated stage plan
class_name StageInstance
extends Resource

var template: StageTemplateResource
var stage_number: int
var generation_seed: int
var planned_rooms: Array[RoomResource] = []

var current_index: int = 0  ## pointer to current room

func _init(p_template: StageTemplateResource, p_stage_number: int, p_seed: int, p_rooms: Array[RoomResource] = []) -> void:
    template = p_template
    stage_number = p_stage_number
    generation_seed = p_seed
    planned_rooms = p_rooms.duplicate()
    current_index = 0

func get_current_room() -> RoomResource:
    if current_index >= 0 and current_index < planned_rooms.size():
        return planned_rooms[current_index]
    return null

func advance() -> void:
    current_index += 1

func is_finished() -> bool:
    return current_index >= planned_rooms.size()

func boss_room() -> RoomResource:
    if planned_rooms.is_empty():
        return null
    return planned_rooms[planned_rooms.size() - 1]