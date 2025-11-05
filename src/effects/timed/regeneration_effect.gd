class_name RegenerationEffect extends TimedEffect

@export var healing_per_turn: int = 2

func get_effect_id() -> String:
    return "regeneration"

func get_effect_name() -> String:
    return "Regeneration"

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

func get_magnitude() -> int:
    return healing_per_turn

# Override apply_effect to implement healing logic
func apply_effect(target: CombatEntity) -> bool:
    # Apply healing to target
    target.heal(healing_per_turn)

    # Use new pattern-based logging
    LogManager.log_event("{You} {action} {healing:%d} from {effect:%s}!" % [healing_per_turn, get_effect_name()], {"target": target, "action": ["heal", "heals"], "status_effect": self})

    return true

func get_description() -> String:
    return "+%d HP for %d turns" % [healing_per_turn, expire_after_turns]

func get_description_with_instance(instance: EffectInstance) -> String:
    if instance:
        return "+%d HP for %d turns" % [healing_per_turn, instance.get_remaining_turns()]
    return get_description()

func get_base_description() -> String:
    return "+%d HP for %d turns" % [healing_per_turn, expire_after_turns]

