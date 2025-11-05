class_name ConditionNameTest extends BaseTest

# Test if there's a mismatch between condition names and effect IDs
func test_condition_name_vs_effect_id() -> bool:
    print("=== CONDITION NAME VS EFFECT ID TEST ===")

    # Create the exact same setup as the integration test
    var player := TestCombatEntity.new()
    var poison := TestPoisonEffect.new()
    poison.set_expire_after_turns(2)

    print("Before application:")
    print("  effect_id: '", poison.get_effect_id(), "'")
    print("  effect_name: '", poison.get_effect_name(), "'")

    # Apply the effect
    var applied := player.apply_status_effect(poison)
    print("Effect applied: ", applied)

    # Check what's actually in active_conditions
    var conditions := player.status_effect_component.active_conditions
    print("Active conditions keys:")
    for key: String in conditions.keys():
        print("  Key: '", key, "'")
        var condition := conditions[key]
        print("    condition.name: '", condition.name, "'")
        print("    effect.get_effect_id(): '", condition.status_effect.get_effect_id(), "'")
        print("    effect.get_effect_name(): '", condition.status_effect.get_effect_name(), "'")

    # Test has_status_effect lookup
    print("Lookup tests:")
    print("  has_status_effect('poison'): ", player.has_status_effect("poison"))
    print("  has_status_effect('Poison'): ", player.has_status_effect("Poison"))

    return true

class TestCombatEntity extends CombatEntity:
    func _init() -> void:
        _init_combat_entity(100, 10, 5)

    func get_name() -> String:
        return "Test Entity"

class TestPoisonEffect extends TimedEffect:
    func get_effect_id() -> String:
        return "poison"

    func get_effect_name() -> String:
        return "Poison"

    func get_effect_type() -> EffectType:
        return EffectType.NEGATIVE

    func apply_effect(_target: CombatEntity) -> bool:
        return true