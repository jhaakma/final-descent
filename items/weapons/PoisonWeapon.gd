@tool
class_name PoisonWeapon extends ItemWeapon

@export var poison_damage_per_turn: int = 1
@export var poison_turns: int = 2
@export var poison_chance: float = 0.5  # 50% chance to apply poison

func _init() -> void:
    super._init()
    name = "Poison Weapon"
    description = "A weapon coated with poison."

func get_description() -> String:
    return "%s\nDamage: %d\nPoison: %d dmg for %d turns (%.0f%% chance)" % [description, damage, poison_damage_per_turn, poison_turns, poison_chance * 100]

# This method will be called when attacking with this weapon
func on_attack_hit(target_enemy) -> void:
    if randf() < poison_chance:
        var poison_effect = PoisonEffect.new(poison_damage_per_turn, poison_turns)
        LogManager.log_poison("Your %s applies poison!" % name)
        target_enemy.apply_status_effect(poison_effect)