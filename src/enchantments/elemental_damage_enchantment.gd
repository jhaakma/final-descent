class_name ElementalDamageEnchantment extends OnStrikeEnchantment

@export var elemental_damage_type: DamageType.Type = DamageType.Type.FIRE
@export var elemental_damage: int = 2
@export var elemental_damage_chance: float = 1.0  # Chance to apply elemental damage

func get_enchantment_name() -> String:
    return "%s Strike" % DamageType.get_type_name(elemental_damage_type)

func get_description() -> String:
    var chance_text := ""
    if elemental_damage_chance < 1.0:
        chance_text = "%.0f%% chance to deal " % (elemental_damage_chance * 100)
    else:
        chance_text = "Deals "

    return "%s%d additional %s damage on attack" % [
        chance_text,
        elemental_damage,
        DamageType.get_type_name(elemental_damage_type).to_lower()
    ]

func on_strike(target: CombatEntity) -> void:
    if randf() < elemental_damage_chance:
        # Apply bonus elemental damage as a separate damage instance
        var final_elemental_damage := target.calculate_incoming_damage(elemental_damage, elemental_damage_type)
        final_elemental_damage = target.take_damage(final_elemental_damage)

        if final_elemental_damage > 0:
            var damage_type_name := DamageType.get_type_name(elemental_damage_type).to_lower()
            LogManager.log_event("The %s enchantment deals {damage:%d}!" % [damage_type_name, final_elemental_damage], {"target": target, "damage_type": elemental_damage_type})
