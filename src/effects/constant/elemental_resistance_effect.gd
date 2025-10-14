class_name ElementalResistanceEffect extends ConstantEffect

@export var elemental_type: DamageType.Type = DamageType.Type.FIRE

func get_effect_id() -> String:
    return "%s_resistance" % DamageType.get_type_name(elemental_type).to_lower()

func get_effect_name() -> String:
    return "%s Resistance" % DamageType.get_type_name(elemental_type)

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Called when the effect is first applied to an entity
func on_applied(target: CombatEntity) -> void:
    if target.has_method("add_damage_resistance"):
        target.add_damage_resistance(elemental_type)

# Called when the effect is removed from an entity
func on_removed(target: CombatEntity) -> void:
    if target.has_method("remove_damage_resistance"):
        target.remove_damage_resistance(elemental_type)

# Override get_description for resistance formatting
func get_description() -> String:
    var type_name := DamageType.get_type_name(elemental_type)
    return "%s Resistance" % type_name

func get_base_description() -> String:
    var type_name := DamageType.get_type_name(elemental_type)
    var desc := "%s Resistance (50%% damage reduction)" % type_name
    if is_permanent():
        return "%s (permanent)" % desc
    else:
        return "%s (constant)" % desc