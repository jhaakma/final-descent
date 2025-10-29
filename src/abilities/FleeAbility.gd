class_name FleeAbility extends AbilityResource

func _init() -> void:
    ability_name = "Flee"
    description = "Attempt to flee from combat."
    priority = 20  # High priority when chosen

func execute(_instance: AbilityInstance, caster: CombatEntity, _target: CombatEntity = null) -> void:
    var success: bool = randf() < caster.flee_chance

    # Log the flee attempt with new pattern-based approach
    if success:
        LogManager.log_event("{You} flee successfully!", {"target": caster})
    else:
        LogManager.log_event("{You} fail to flee!", {"target": caster})

func get_ability_type() -> AbilityResource.AbilityType:
    return AbilityResource.AbilityType.FLEE

func can_use(caster: CombatEntity) -> bool:
    # Can always attempt to flee if alive
    return caster != null and caster.has_method("is_alive") and caster.is_alive()