class_name InstantDamageEffect extends StatusEffect

@export var damage_amount: int = 5
@export var damage_type: DamageType.Type = DamageType.Type.PHYSICAL

func get_effect_id() -> String:
    return "instant_damage"

func get_effect_name() -> String:
    return DamageType.get_type_name(damage_type)

func get_effect_type() -> EffectType:
    return EffectType.NEGATIVE

func apply_effect(target: CombatEntity) -> bool:
    if not target:
        return false

    # Calculate damage after resistances
    var final_damage := target.calculate_incoming_damage(damage_amount, damage_type)

    # Apply the damage
    var actual_damage := target.take_damage(final_damage)

    if actual_damage > 0:
        var damage_type_name := DamageType.get_type_name(damage_type).to_lower()

        # Use application context for better logging if available
        var source_name: String
        if application_context and application_context.log_ability_name:
            source_name = application_context.name
        else:
            source_name = get_effect_name()

        LogManager.log_damage("%s deals %d %s damage!" % [source_name, actual_damage, damage_type_name], target, damage_type)

    return actual_damage > 0

func get_description() -> String:
    var damage_type_name := DamageType.get_type_name(damage_type)
    return "Deals %d %s damage" % [damage_amount, damage_type_name]

func get_base_description() -> String:
    return get_description()

# Override: instant effects are not stored
func should_store_in_active_conditions() -> bool:
    return false