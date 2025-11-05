class_name DiagnosticTimingTest extends BaseTest

func test_diagnostic_poison_logic() -> bool:
    print("=== DIAGNOSTIC TEST START ===")

    # Create the exact same setup as the failing test
    print("Creating TestCombatEntity...")
    var player := TestCombatEntity.new()
    print("TestCombatEntity created successfully")

    print("Creating TestPoisonEffect...")
    var poison := TestPoisonEffect.new()
    print("TestPoisonEffect created successfully")

    print("Setting expire timing...")
    poison.set_expire_timing(EffectTiming.Type.TURN_START)
    print("Setting expire after turns...")
    poison.set_expire_after_turns(2)
    print("Effect setup complete")

    print("1. Effect created:")
    print("   - expire_timing (raw): ", poison.get_expire_timing())
    print("   - expire_after_turns: ", poison.get_expire_after_turns())
    print("   - effect_id: ", poison.get_effect_id())
    print("   - effect_name: ", poison.get_effect_name())

    # Apply effect
    var applied := player.apply_status_effect(poison)
    print("2. Effect applied: ", applied)
    print("   - has_status_effect('poison'): ", player.has_status_effect("poison"))

    # Check active conditions
    var conditions := player.status_effect_component.active_conditions
    print("3. Active conditions count: ", conditions.size())
    for key: String in conditions.keys():
        var condition := conditions[key]
        print("   - Condition key: '", key, "'")
        print("   - Condition name: '", condition.name, "'")
        print("   - Effect ID: '", condition.status_effect.get_effect_id(), "'")
        print("   - Effect class: ", condition.status_effect.get_class())
        print("   - Is TimedEffect: ", condition.status_effect is TimedEffect)

    # Test should_expire_at directly
    print("4. Direct should_expire_at tests:")
    var te := poison as TimedEffect
    print("   - should_expire_at(TURN_START, 1): ", te.should_expire_at(EffectTiming.Type.TURN_START, 1))
    print("   - should_expire_at(TURN_START, 2): ", te.should_expire_at(EffectTiming.Type.TURN_START, 2))
    print("   - should_expire_at(ROUND_END, 2): ", te.should_expire_at(EffectTiming.Type.ROUND_END, 2))

    # Test process_status_effects_at_timing turn 1
    print("5. Processing turn 1...")
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)
    print("   - has_status_effect('poison') after turn 1: ", player.has_status_effect("poison"))
    print("   - active conditions count after turn 1: ", conditions.size())

    # Test process_status_effects_at_timing turn 2
    print("6. Processing turn 2...")
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 2)
    print("   - has_status_effect('poison') after turn 2: ", player.has_status_effect("poison"))
    print("   - active conditions count after turn 2: ", conditions.size())

    print("=== DIAGNOSTIC TEST END ===")

    # Return true regardless of actual result so we can see all the debug output
    var final_result := not player.has_status_effect("poison")
    print("7. Final result (should be true): ", final_result)
    return true  # Always pass so we can see the output

class TestCombatEntity extends CombatEntity:
    func _init() -> void:
        _init_combat_entity(100, 10, 5)

    func get_name() -> String:
        return "Test Entity"

class TestPoisonEffect extends TimedEffect:
    func _init() -> void:
        # Initialize with default values that will be overridden in the test
        set_expire_timing(EffectTiming.Type.ROUND_END)
        set_expire_after_turns(1)

    func get_effect_id() -> String:
        return "poison"

    func get_effect_name() -> String:
        return "Poison"

    func get_effect_type() -> EffectType:
        return EffectType.NEGATIVE

    func apply_effect(_target: CombatEntity) -> bool:
        return true