class_name EffectTiming

## Enumeration defining when during combat status effects should expire
## Values are ordered chronologically to allow for proper timing control
## ROUND = Complete cycle where all actors have acted once
enum Type {
    ROUND_START = 0,   # Beginning of combat round, before any actor acts
    TURN_START = 1,    # Beginning of individual actor's turn, when they can take actions
    _TURN_END = 2,      # End of individual turn, after an actor's actions
    ROUND_END = 3      # End of combat round, after all actors have acted
}

## Check if the enum has a specific phase name
static func has(phase_name: String) -> bool:
    match phase_name:
        "ROUND_START", "TURN_START", "ROUND_END":
            return true
        _:
            return false

## Get the string name for a timing value
static func get_name(timing_value: Type) -> String:
    match timing_value:
        Type.ROUND_START:
            return "ROUND_START"
        Type.TURN_START:
            return "TURN_START"
        Type.ROUND_END:
            return "ROUND_END"
        _:
            return "UNKNOWN"

## Get all timing phases in order
static func get_all_phases() -> Array[Type]:
    return [Type.ROUND_START, Type.TURN_START, Type.ROUND_END]
