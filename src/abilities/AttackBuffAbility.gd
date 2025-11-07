class_name AttackBuffAbility extends AbilityResource
## Applies a temporary attack boost to the user for 1 turn

@export var attack_bonus: int = 3  # Amount of attack to boost
@export var duration: int = 1  # Duration of the buff in turns

func _init() -> void:
    ability_name = "Attack Boost"
    description = "Boosts attack power temporarily."
    priority = 12  # Medium-high priority for strategic abilities

func execute(_instance: AbilityInstance, caster: CombatEntity, _target: CombatEntity = null) -> void:
    if caster == null:
        push_error("AttackBuffAbility requires a caster")
        return

    # Create the attack boost effect
    var effect := AttackBoostEffect.new()
    effect.attack_bonus = attack_bonus
    effect.expire_after_turns = duration

    # Apply the effect to the caster
    if caster.has_method("apply_status_effect"):
        caster.apply_status_effect(effect)
    else:
        push_error("Caster does not support status effects (missing apply_status_effect method)")

    # Mark single-turn ability as completed immediately
    _instance.current_state = AbilityInstance.AbilityState.COMPLETED

func get_ability_type() -> AbilityResource.AbilityType:
    return AbilityResource.AbilityType.SUPPORT

func can_use(caster: CombatEntity) -> bool:
    return (caster != null and
            caster.has_method("is_alive") and
            caster.is_alive())
