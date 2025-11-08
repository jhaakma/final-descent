## stage_instance.gd
## Runtime representation of a generated stage plan
class_name StageInstance
extends Resource

var template: StageTemplateResource
var generation_seed: int
var planned_rooms: Array[RoomResource] = []   ## ordered rooms; last is boss
var integrity_ok: bool = true

var current_index: int = 0  ## pointer to current room

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