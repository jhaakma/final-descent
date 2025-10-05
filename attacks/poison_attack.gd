extends SpecialAttack
class_name PoisonAttack

@export var poison_damage_per_turn: int = 2
@export var poison_duration: int = 3

func _init():
    attack_name = "Poison Attack"
    base_damage = 3
    description = "An attack that poisons the target."

func execute_attack(attacker_name: String, target) -> String:
    var damage = get_damage()
    var message = "%s uses %s for %d damage!" % [attacker_name, attack_name, damage]

    # Apply poison effect to target using the new status effect system
    if target.has_method("apply_status_effect"):
        var poison_effect = PoisonEffect.new(poison_damage_per_turn, poison_duration)
        target.apply_status_effect(poison_effect)
        message += " The target has been poisoned!"

    return message

func get_damage() -> int:
    return base_damage + randi() % 3

func can_use(_attacker) -> bool:
    return true

func get_description() -> String:
    return "%s\nDamage: %d + poison (%d dmg for %d turns)" % [description, base_damage, poison_damage_per_turn, poison_duration]