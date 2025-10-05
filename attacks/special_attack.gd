class_name SpecialAttack extends Resource

@export var attack_name: String = "Special Attack"
@export var base_damage: int = 0
@export var description: String = "A special attack."
@export var use_chance: float = 0.5

# Abstract method - override in subclasses to define specific attack effects
func execute_attack(_attacker_name: String, _target) -> String:
    push_error("execute_attack() must be implemented in SpecialAttack subclass")
    return ""

# Get the actual damage this attack will deal (can be overridden for variable damage)
func get_damage() -> int:
    return base_damage + randi() % 3

# Check if this attack can be used (can be overridden for conditions)
func can_use(_attacker) -> bool:
    return true