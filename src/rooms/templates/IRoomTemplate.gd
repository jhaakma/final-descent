class_name IRoomTemplate extends Resource
## Base interface for room templates - defines contract for room generation
##
## All room templates must implement this interface to work with the StageGenerator.
## Subclasses can choose to use variant arrays (RoomTemplate), compute properties
## dynamically (DynamicRoomTemplate), or implement completely custom logic.

@export var rarity: Rarity.Type = Rarity.Type.COMMON
@export var min_floor: int = 1
@export var max_floor: int = 999


func get_room_type() -> RoomType.Type:
    return RoomType.Type.NONE

## Generate the actual RoomResource with stage-based scaling
## This is the primary method that must be overridden by all subclasses
## @param stage: The current stage/floor number for scaling purposes
## @return: A fully configured RoomResource ready for use
func generate_room(_stage: int) -> RoomResource:
    push_error("IRoomTemplate.generate_room() must be overridden")
    return null

## Check if this template is valid for the given floor
func valid_for_floor(floor_number: int) -> bool:
    if floor_number < min_floor:
        return false
    if max_floor >= 0 and floor_number > max_floor:
        return false
    return true

func apply_common_properties(room: RoomResource) -> void:
    room.room_type = get_room_type()
    room.rarity = rarity
    room.min_floor = min_floor
    room.max_floor = max_floor