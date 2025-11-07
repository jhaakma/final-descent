class_name PreparationAbility extends AbilityResource

@export var prepared_ability: AbilityResource = null  # The ability to execute next turn
@export var player_preparation_text: String = "prepare for something..."
@export var enemy_preparation_text: String = "prepares for something..."

func _init() -> void:
    ability_name = "Preparation"
    description = "Prepare to perform a powerful ability next turn."
    priority = 15  # High priority for strategic abilities

func execute(instance: AbilityInstance, caster: CombatEntity, target: CombatEntity = null) -> void:
    # Start the preparation phase
    instance._start_execution(caster, target)

    var preparation_text := player_preparation_text if caster == GameState.player else enemy_preparation_text

    # Log the preparation
    var caster_name := _get_target_name(caster)
    LogManager.log_event("%s %s" % [caster_name.capitalize(), preparation_text])

func continue_execution(instance: AbilityInstance) -> void:
    # Execute the prepared ability on the second turn
    if prepared_ability != null and instance.caster_ref != null:
        print("PreparationAbility: Executing prepared ability '%s'" % prepared_ability.ability_name)
        # Create a temporary instance for the prepared ability
        var prepared_instance := AbilityInstance.new(prepared_ability)
        prepared_ability.execute(prepared_instance, instance.caster_ref, instance.target_ref)

    # Mark preparation as completed
    instance.current_state = AbilityInstance.AbilityState.COMPLETED

func get_ability_type() -> AbilityResource.AbilityType:
    if prepared_ability != null:
        return prepared_ability.get_ability_type()
    return AbilityResource.AbilityType.SUPPORT

func can_use(caster: CombatEntity) -> bool:
    return (caster != null and
            caster.has_method("is_alive") and
            caster.is_alive() and
            prepared_ability != null)

func get_status_text(instance: AbilityInstance, _caster: CombatEntity) -> String:
    if instance.current_state == AbilityInstance.AbilityState.EXECUTING:
        return "Prepared: %s" % (prepared_ability.ability_name if prepared_ability else "Unknown")
    return ""

func _get_target_name(target: CombatEntity) -> String:
    if target == GameState.player:
        return "you"
    elif target.has_method("get_name"):
        return target.get_name()
    else:
        return "unknown"
