class_name ArmorResistanceEffect extends ConstantEffect
## Equipment-based resistance effect that provides damage reduction
## Uses same effect IDs as elemental resistance effects for proper stacking

@export var elemental_type: DamageType.Type = DamageType.Type.FIRE
@export var source_armor_name: String = ""

func get_effect_id() -> String:
    # Use same ID pattern as ElementalResistanceEffect for stacking/deduplication
    return "%s_resistance" % DamageType.get_type_name(elemental_type).to_lower()

func get_effect_name() -> String:
    return "%s Resistance" % DamageType.get_type_name(elemental_type)

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_magnitude() -> int:
    return 1  # Boolean resistance effect has magnitude of 1

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
    if source_armor_name.is_empty():
        return "50%% %s damage reduction." % type_name
    else:
        return "50%% %s damage reduction from %s." % [type_name, source_armor_name]

func get_base_description() -> String:
    var type_name := DamageType.get_type_name(elemental_type)
    var desc := "%s Resistance" % type_name
    if not source_armor_name.is_empty():
        desc += " from %s" % source_armor_name

    # Armor resistances are permanent while equipped
    return "%s (equipment)" % desc