class_name ElementalTimedEffect extends TimedEffect

@export var damage_per_turn: int = 2
@export var elemental_type: DamageType.Type = DamageType.Type.POISON

func get_effect_name() -> String:
    return DamageType.get_type_name(elemental_type)

func get_effect_type() -> EffectType:
    return EffectType.NEGATIVE

# Override apply_effect to implement elemental damage logic
func apply_effect(target: CombatEntity) -> bool:
    # Apply elemental damage considering resistances
    var final_damage := target.calculate_incoming_damage(damage_per_turn, elemental_type)
    final_damage = target.take_damage(final_damage)

    # Use enhanced logging with target context
    LogManager.log_status_effect_damage(target, get_effect_name(), final_damage, elemental_type)

    return true

func get_base_description() -> String:
    var type_name := DamageType.get_type_name(elemental_type).to_lower()
    return "%d %s damage for %d turns" % [damage_per_turn, type_name, duration]