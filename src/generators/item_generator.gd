class_name ItemGenerator extends Resource
## Abstract base class for generating items dynamically
## Used in loot tables as an alternative to static item lists

@export var generation_weight: float = 1.0
@export var floor_min: int = 0
@export var floor_max: int = -1  # -1 means no maximum

## Virtual method to generate a single item
## Override this in subclasses to implement specific generation logic
func generate_item() -> Item:
    push_error("generate_item() must be implemented by subclass")
    return null

## Check if this generator can be used on the current floor
func is_valid_for_floor(floor_level: int) -> bool:
    if floor_level < floor_min:
        return false
    if floor_max >= 0 and floor_level > floor_max:
        return false
    return true

## Get the weight for weighted random selection
func get_weight() -> float:
    return generation_weight if is_valid_for_floor(GameState.current_floor) else 0.0