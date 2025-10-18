class_name ElementalResistanceTimedEffect extends TimedEffect

@export var elemental_type: DamageType.Type = DamageType.Type.FIRE

func get_effect_id() -> String:
    return "%s_resistance_timed" % DamageType.get_type_name(elemental_type).to_lower()

func get_effect_name() -> String:
    return "%s Resistance" % DamageType.get_type_name(elemental_type)

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_magnitude() -> int:
    return 1  # Boolean resistance effect has magnitude of 1

func on_applied(target: CombatEntity) -> void:
    if target.has_method("add_damage_resistance"):
        target.add_damage_resistance(elemental_type)

func on_removed(target: CombatEntity) -> void:
    if target.has_method("remove_damage_resistance"):
        target.remove_damage_resistance(elemental_type)

func get_description() -> String:
    var type_name := DamageType.get_type_name(elemental_type)
    return "%s resistance for %d turns" % [type_name, get_remaining_turns()]

func get_base_description() -> String:
    var type_name := DamageType.get_type_name(elemental_type)
    return "%s Resistance (50%% damage reduction) for %d turns" % [type_name, duration]