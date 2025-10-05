@tool
class_name InflictingWeapon extends ItemWeapon

@export var status_effect: StatusEffect = null  # The status effect to apply
@export var effect_apply_chance: float = 0.3  # Chance to apply the effect (0.0 to 1.0)

func _init() -> void:
    super._init()
    name = "Inflicting Weapon"
    description = "A weapon that inflicts a status effect on hit."

func get_description() -> String:
    return "%s\nDamage: %d\n%s%% chance to inflict %s" % [
        description,
        damage,
        int(effect_apply_chance * 100),
        status_effect.effect_name if status_effect != null else "No Effect"
    ]
# This method will be called when attacking with this weapon
func on_attack_hit(target_enemy) -> void:
    if randf() < effect_apply_chance:
        var inflicted_effect = status_effect.duplicate()
        LogManager.log_inflict_status("Your %s inflicts %s!" % [name, inflicted_effect.effect_name])
        target_enemy.apply_status_effect(inflicted_effect)
