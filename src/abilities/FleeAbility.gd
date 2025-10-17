class_name FleeAbility extends Ability

func _init() -> void:
    ability_name = "Flee"
    description = "Attempt to flee from combat."
    priority = 20  # High priority when chosen

func execute(caster: CombatEntity, _target: CombatEntity = null) -> void:
    var success: bool = randf() < caster.flee_chance

    # Log the flee attempt with new pattern-based approach
    if success:
        LogManager.log_event("{You} flee successfully!", {"target": caster})
        caster.action_performed.emit("flee_success", 0, "")
    else:
        LogManager.log_event("{You} fail to flee!", {"target": caster})
        caster.action_performed.emit("flee_fail", 0, "")

func get_ability_type() -> Ability.AbilityType:
    return Ability.AbilityType.FLEE

func can_use(caster) -> bool:
    # Can always attempt to flee if alive
    return caster != null and caster.has_method("is_alive") and caster.is_alive()