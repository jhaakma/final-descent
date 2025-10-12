class_name StatusOnStrikeEnchantment extends OnStrikeEnchantment

@export var status_effect: StatusEffect
@export var effect_apply_chance: float = 0.2  # Chance to apply the condition (0.0 to 1.0)

func on_strike(target: CombatEntity) -> void:
    if randf() < effect_apply_chance:
        LogManager.log_damage("You inflict %s on %s!" % [status_effect.get_effect_name(), target.get_name()], false)
        target.apply_status_effect(status_effect)

func get_enchantment_name() -> String:
    return status_effect.get_effect_name()

func get_description() -> String:
    var name := "On Strike: %.0f%% chance to inflict %s" % [effect_apply_chance * 100, status_effect.get_base_description()]
    return name