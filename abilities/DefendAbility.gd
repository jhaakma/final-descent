class_name DefendAbility extends Ability

@export var defense_multiplier: float = 0.5  # How much damage reduction when defending

func _init() -> void:
    ability_name = "Defend"
    description = "Prepare to defend against incoming attacks."
    priority = 5

func execute(caster, _target = null) -> void:
    # Apply unified defend action for both players and enemies
    if caster.has_method("set_defending"):
        # Use the unified defending system with configurable multiplier
        caster.set_defending(true)
        # Store the defense multiplier in the combat actor for use in damage calculation
        caster.combat_actor.set_defense_multiplier(defense_multiplier)
    else:
        push_error("DefendAbility: Caster does not support defending system")

    # Log the defend action
    LogManager.log_defend(caster)

func get_ability_type() -> Ability.AbilityType:
    return Ability.AbilityType.DEFEND

func can_use(caster) -> bool:
    # Check if can defend
    if not caster or not caster.has_method("is_alive") or not caster.is_alive():
        return false

    # Check via the unified defending interface
    if caster.has_method("get_is_defending"):
        return not caster.get_is_defending()

    return false
