class_name SpecialAttack extends Resource

@export var attack_name: String = "Special Attack"
@export var base_damage: int = 0
@export var description: String = "A special attack."
@export var use_chance: float = 0.5
@export var status_effect: StatusEffect = null  # Optional status effect to apply

# Abstract method - override in subclasses to define specific attack effects
func execute_attack(attacker, target) -> String:
    var damage = get_damage()

    # Apply damage to target
    target.take_damage(damage)

    # Check for status effect application
    var additional_effects = ""
    if status_effect != null:
        print("Status effect applied!")
        target.apply_status_effect(status_effect)
        additional_effects = "Afflicted with %s!" % status_effect.effect_name

    # Log the special attack with proper context
    LogManager.log_special_attack(attacker, target, attack_name, damage, additional_effects)

    return ""  # Return empty string since logging is now handled internally

# Get the actual damage this attack will deal (can be overridden for variable damage)
func get_damage() -> int:
    return base_damage

# Check if this attack can be used (can be overridden for conditions)
func can_use(_attacker) -> bool:
    return true