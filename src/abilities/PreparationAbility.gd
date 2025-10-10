class_name PreparationAbility extends Ability

@export var prepared_ability: Ability = null  # The ability to execute next turn
@export var preparation_text: String = "prepares for something..."

func _init() -> void:
    ability_name = "Preparation"
    description = "Prepare to perform a powerful ability next turn."
    priority = 15  # High priority for strategic abilities

func execute(caster: CombatEntity, target: CombatEntity = null) -> void:
    # Start the preparation phase
    _start_execution(caster, target)

    # Log the preparation
    var caster_name := _get_target_name(caster)
    LogManager.log_combat("%s %s" % [caster_name.capitalize(), preparation_text])

func continue_execution() -> void:
    # Execute the prepared ability on the second turn
    if prepared_ability != null and caster_ref != null:
        print("PreparationAbility: Executing prepared ability '%s'" % prepared_ability.ability_name)
        prepared_ability.execute(caster_ref, target_ref)

    # Mark preparation as completed
    current_state = AbilityState.COMPLETED

func get_ability_type() -> Ability.AbilityType:
    return prepared_ability.get_ability_type()

func can_use(caster: CombatEntity) -> bool:
    return (caster != null and
            caster.has_method("is_alive") and
            caster.is_alive() and
            prepared_ability != null and
            current_state == AbilityState.READY)

func get_status_text(_caster: CombatEntity) -> String:
    if current_state == AbilityState.EXECUTING:
        return "Prepared: %s" % (prepared_ability.ability_name if prepared_ability else "Unknown")
    return ""

func _get_target_name(target: CombatEntity) -> String:
    if target == GameState.player:
        return "you"
    elif target.has_method("get_name"):
        return target.get_name()
    else:
        return "unknown"
