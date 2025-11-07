class_name RecoveryAbility extends AbilityResource
## Applies a multi-turn regeneration effect to heal over time

@export var healing_per_turn: int = 2  # Amount of HP healed per turn
@export var duration: int = 3  # Duration of the regeneration in turns

func _init() -> void:
    ability_name = "Recovery"
    description = "Gradually restores health over multiple turns."
    priority = 10  # Medium priority for healing abilities
    cooldown = 1  # Cooldown period after use

func execute(instance: AbilityInstance, caster: CombatEntity, _target: CombatEntity = null) -> void:
    if caster == null:
        push_error("RecoveryAbility requires a caster")
        return

    # Create the regeneration effect
    var effect := RegenerationEffect.new()
    effect.healing_per_turn = healing_per_turn
    effect.expire_after_turns = duration
    effect.log_effect = true
    # Apply the effect to the caster
    if caster.has_method("apply_status_effect"):
        caster.apply_status_effect(effect)
    else:
        push_error("Caster does not support status effects (missing apply_status_effect method)")

    LogManager.log_event("{You} {action}", {
        "target": caster,
        "action": ["begin to recover health", "begins to recover health"]
    })

    # Mark single-turn ability as completed immediately
    instance.current_state = AbilityInstance.AbilityState.COMPLETED

func on_select(_instance: AbilityInstance, caster: CombatEntity) -> void:
    execute(_instance, caster)

func get_ability_type() -> AbilityResource.AbilityType:
    return AbilityResource.AbilityType.SUPPORT

func can_use(caster: CombatEntity) -> bool:
    # Can use if caster is alive and not at full health
    if caster == null or not caster.has_method("is_alive") or not caster.is_alive():
        return false

    # Check if already at full health
    if caster.has_method("get_current_hp") and caster.has_method("get_max_hp"):
        return caster.get_current_hp() < caster.get_max_hp()

    return true
