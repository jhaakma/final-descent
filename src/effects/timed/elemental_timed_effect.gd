class_name ElementalTimedEffect extends TimedEffect

@export var damage_per_turn: int = 2
@export var elemental_type: DamageType.Type = DamageType.Type.POISON

func get_effect_name() -> String:
    return DamageType.get_type_name(elemental_type)

func get_effect_type() -> EffectType:
    return EffectType.NEGATIVE

func get_magnitude() -> int:
    return damage_per_turn

# Override apply_effect to implement elemental damage logic
func apply_effect(target: CombatEntity) -> bool:
    print("DEBUG: ElementalTimedEffect.apply_effect() called for ", get_effect_name(), " on ", target.get_name())
    print("DEBUG: Damage per turn: ", damage_per_turn, ", Target current HP: ", target.get_current_hp())

    # Apply elemental damage considering resistances
    var final_damage := target.calculate_incoming_damage(damage_per_turn, elemental_type)
    final_damage = target.take_damage(final_damage)

    print("DEBUG: Final damage dealt: ", final_damage, ", Target HP after: ", target.get_current_hp())

    # Use new pattern-based logging
    LogManager.log_event("{You} {action} {damage:%d} from {effect:%s}!" % [final_damage, get_effect_name()], {"target": target, "damage_type": elemental_type, "action": ["take", "takes"], "status_effect": self})

    return true

func get_description() -> String:
    return "%d %s damage for %d turns" % [damage_per_turn, DamageType.get_type_name(elemental_type), get_remaining_turns()]

func get_base_description() -> String:
    return "%d %s damage for %d turns" % [damage_per_turn, DamageType.get_type_name(elemental_type), expire_after_turns]