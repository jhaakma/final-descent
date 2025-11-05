class_name SimpleTimingTest extends BaseTest

# Simple test to isolate the timing issue
func test_poison_timing_direct() -> bool:
    # Create effect directly
    var poison = TimedEffect.new()
    poison.set_expire_timing(EffectTiming.Type.ROUND_START)
    poison.set_expire_after_turns(2)

    # Test the basic logic
    print("Testing should_expire_at logic:")
    print("Turn 1, ROUND_START: ", poison.should_expire_at(EffectTiming.Type.ROUND_START, 1))  # Should be false
    print("Turn 2, ROUND_START: ", poison.should_expire_at(EffectTiming.Type.ROUND_START, 2))  # Should be true

    var result1 = poison.should_expire_at(EffectTiming.Type.ROUND_START, 1)
    var result2 = poison.should_expire_at(EffectTiming.Type.ROUND_START, 2)

    return assert_false(result1) and assert_true(result2)

func test_status_effect_component_direct() -> bool:
    # Create a simple effect and component
    var parent = CombatEntity.new()
    var component = StatusEffectComponent.new(parent)
    var poison = TimedEffect.new()
    poison.set_expire_timing(EffectTiming.Type.ROUND_START)
    poison.set_expire_after_turns(2)

    # Create condition manually
    var condition = StatusCondition.new()
    condition.name = "Poison"
    condition.status_effect = poison

    # Add to component
    component.active_conditions["Poison"] = condition
    poison.initialize()

    print("Conditions before turn 1: ", component.active_conditions.size())

    # Create a simple target
    var target = TestCombatEntity.new()

    # Process turn 1 - should NOT remove
    component.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 1, target)

    print("Conditions after turn 1: ", component.active_conditions.size())
    var has_after_turn1 = component.has_effect("poison")

    # Process turn 2 - should remove
    component.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 2, target)

    print("Conditions after turn 2: ", component.active_conditions.size())
    var has_after_turn2 = component.has_effect("poison")

    return assert_true(has_after_turn1) and assert_false(has_after_turn2)

class TestCombatEntity extends CombatEntity:
    func _init() -> void:
        _init_combat_entity(100, 10, 5)

    func get_name() -> String:
        return "Test Entity"
