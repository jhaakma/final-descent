class_name BuffAbility extends Ability

@export var target_self: bool = true  # Whether this buff targets the caster or target
@export var status_effect_to_apply: StatusEffect = null  # The status effect to apply

func _init() -> void:
    ability_name = "Buff"
    description = "Apply a beneficial effect."
    priority = 12  # Medium-high priority

func execute(caster: CombatEntity, target: CombatEntity = null) -> void:
    # Determine the actual target
    var actual_target := caster if target_self else target
    if actual_target == null:
        push_error("BuffAbility: No valid target available")
        return

    # Apply status effect
    if status_effect_to_apply != null:
        _apply_status_effect(actual_target, caster)
    else:
        push_error("BuffAbility requires status_effect_to_apply to be set")

func _apply_status_effect(actual_target: CombatEntity, caster: CombatEntity) -> void:
    # Create a copy of the status effect to avoid modifying the original resource
    var effect_copy: StatusEffect = status_effect_to_apply.create()

    # Apply the status effect to the target
    if actual_target.has_method("apply_status_effect"):
        actual_target.apply_status_effect(effect_copy)

        # Log the status effect application
        var caster_name: String = _get_target_name(caster)
        var target_name: String = _get_target_name(actual_target)

        if target_self:
            LogManager.log_combat("%s applies %s to themselves!" % [caster_name.capitalize(), ability_name])
        else:
            LogManager.log_combat("%s applies %s to %s!" % [caster_name.capitalize(), effect_copy.get_effect_name(), target_name])
    else:
        push_error("Target does not support status effects (missing apply_status_effect method)")

func get_ability_type() -> Ability.AbilityType:
    return Ability.AbilityType.SUPPORT

func can_use(caster: CombatEntity) -> bool:
    # Can use if caster is alive and has a status effect to apply
    return (caster != null and
            caster.has_method("is_alive") and
            caster.is_alive() and
            status_effect_to_apply != null)

func get_status_text(_caster: CombatEntity) -> String:
    if status_effect_to_apply:
        return "Status Effect: %s" % status_effect_to_apply.get_effect_name()
    return ""

func _get_target_name(target: CombatEntity) -> String:
    if target == GameState.player:
        return "you"
    elif target.has_method("get_name"):
        return target.get_name()
    else:
        return "unknown"
