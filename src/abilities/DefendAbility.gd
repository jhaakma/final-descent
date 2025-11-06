class_name DefendAbility extends AbilityResource

@export var defense_percentage: float = 50.0  # Percentage defense bonus when defending

func _init() -> void:
    ability_name = "Defend"
    description = "Reduce incoming damage by %.0f%% for the next attack." % defense_percentage
    priority = 5

func execute(_instance: AbilityInstance, caster: CombatEntity, _target: CombatEntity = null) -> void:
    # Apply defense boost status effect
    var defend_effect := DefendEffect.new(int(defense_percentage))
    caster.apply_status_effect(defend_effect)

    # Log the defend action
    LogManager.log_event("{You} brace for defense.", {"target": caster})
    _instance.current_state = AbilityInstance.AbilityState.COMPLETED

func get_ability_type() -> AbilityResource.AbilityType:
    return AbilityResource.AbilityType.DEFEND

func can_use(caster: CombatEntity) -> bool:
    # Check if can defend
    if not caster or not caster.has_method("is_alive") or not caster.is_alive():
        return false

    # Check if already has defend effect active
    return not caster.has_status_effect("defend")
