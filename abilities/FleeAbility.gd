class_name FleeAbility extends Ability

func _init() -> void:
    ability_name = "Flee"
    description = "Attempt to flee from combat."
    use_chance = 1.0
    priority = 20  # High priority when chosen

func execute(caster, _target = null) -> void:
    var success = randf() < caster.flee_chance
    LogManager.log_flee_attempt(caster, success)

    if success:
        caster.action_performed.emit("flee_success", 0, "")
    else:
        caster.action_performed.emit("flee_fail", 0, "")

func get_ability_type() -> Ability.AbilityType:
    return Ability.AbilityType.FLEE

func can_use(caster) -> bool:
    # Can always attempt to flee if alive
    return caster != null and caster.has_method("is_alive") and caster.is_alive()