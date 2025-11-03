class_name TimingProcessTest extends BaseTest

# Test the exact timing processing to see what's happening
func test_timing_processing_step_by_step() -> bool:
    print("=== TIMING PROCESSING STEP BY STEP ===")

    # Create the exact same setup as the integration test
    var player := TestCombatEntity.new()
    var poison := TestPoisonEffect.new()
    poison.set_expire_timing(EffectTiming.Type.TURN_START)
    poison.set_expire_after_turns(2)

    # Apply the effect
    player.apply_status_effect(poison)
    print("1. After application:")
    print("   has_status_effect('poison'): ", player.has_status_effect("poison"))
    print("   active_conditions count: ", player.status_effect_component.active_conditions.size())

    # Process turn 1 - should NOT remove
    print("2. Processing turn 1...")
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)
    print("   has_status_effect('poison'): ", player.has_status_effect("poison"))
    print("   active_conditions count: ", player.status_effect_component.active_conditions.size())

    # Check the effect properties before turn 2
    var conditions := player.status_effect_component.active_conditions
    for key: String in conditions.keys():
        var condition := conditions[key]
        if condition.status_effect is TimedEffect:
            var te := condition.status_effect as TimedEffect
            print("   Effect properties before turn 2:")
            print("     expire_timing: ", te.expire_timing)
            print("     expire_after_turns: ", te.expire_after_turns)
            print("     should_expire_at(TURN_START, 2): ", te.should_expire_at(EffectTiming.Type.TURN_START, 2))

    # Process turn 2 - should remove
    print("3. Processing turn 2...")
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 2)
    print("   has_status_effect('poison'): ", player.has_status_effect("poison"))
    print("   active_conditions count: ", player.status_effect_component.active_conditions.size())

    # Final check
    var should_be_removed := not player.has_status_effect("poison")
    print("4. Test result (should be true): ", should_be_removed)

    return should_be_removed

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