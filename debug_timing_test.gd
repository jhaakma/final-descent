extends BaseTest

# Debug script to test timing logic step by step
func debug_timing_issue():
    print("=== DEBUG TIMING ISSUE ===")

    # Create test effect
    var poison = TimedEffect.new()
    poison.set_expire_timing(EffectTiming.Type.TURN_START)
    poison.set_expire_after_turns(2)

    print("Effect timing: ", EffectTiming.get_name(poison.get_expire_timing()))
    print("Effect expire after turns: ", poison.get_expire_after_turns())

    # Test should_expire_at logic
    print("\n=== Testing should_expire_at logic ===")
    print("Turn 1, TURN_START: ", poison.should_expire_at(EffectTiming.Type.TURN_START, 1))  # Should be false
    print("Turn 2, TURN_START: ", poison.should_expire_at(EffectTiming.Type.TURN_START, 2))  # Should be true
    print("Turn 2, TURN_END: ", poison.should_expire_at(EffectTiming.Type.TURN_END, 2))      # Should be false (wrong timing)

    # Create test entity and apply effect
    var entity = TestCombatEntity.new()
    var condition = StatusCondition.new("poison", poison)

    print("\n=== Testing StatusEffectComponent integration ===")
    print("Active conditions before application: ", entity.status_effect_component.active_conditions.size())

    entity.status_effect_component.active_conditions["poison"] = condition
    poison.initialize()

    print("Active conditions after application: ", entity.status_effect_component.active_conditions.size())
    print("Has poison effect: ", entity.has_status_effect("poison"))

    # Process turn 1
    print("\n=== Processing Turn 1 ===")
    entity.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)
    print("Active conditions after turn 1: ", entity.status_effect_component.active_conditions.size())
    print("Has poison effect: ", entity.has_status_effect("poison"))

    # Process turn 2
    print("\n=== Processing Turn 2 ===")
    entity.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 2)
    print("Active conditions after turn 2: ", entity.status_effect_component.active_conditions.size())
    print("Has poison effect: ", entity.has_status_effect("poison"))

class TestCombatEntity extends CombatEntity:
    func _init() -> void:
        _init_combat_entity(100, 10, 5)

    func get_name() -> String:
        return "Test Entity"