class_name ShouldExpireAtTest extends BaseTest

# Test the should_expire_at method in isolation to confirm it works correctly
func test_should_expire_at_basic_logic() -> bool:
    var effect := TimedEffect.new()

    # Test with default values (TURN_END, expire_after_turns = 1)
    var result1 := effect.should_expire_at(EffectTiming.Type.TURN_END, 1)
    if not assert_true(result1):
        print("FAIL: Default should expire at TURN_END, turn 1")
        return false

    var result2 := effect.should_expire_at(EffectTiming.Type.TURN_END, 0)
    if not assert_false(result2):
        print("FAIL: Should not expire at turn 0")
        return false

    var result3 := effect.should_expire_at(EffectTiming.Type.TURN_START, 1)
    if not assert_false(result3):
        print("FAIL: Should not expire at wrong timing")
        return false

    print("PASS: Basic logic works correctly")
    return true

func test_should_expire_at_turn_start_timing() -> bool:
    var effect := TimedEffect.new()
    effect.set_expire_timing(EffectTiming.Type.TURN_START)
    effect.set_expire_after_turns(2)

    print("Effect setup:")
    print("  expire_timing (raw): ", effect.get_expire_timing())
    print("  expire_after_turns: ", effect.get_expire_after_turns())

    # Test the exact scenario from the failing integration test
    var result1 := effect.should_expire_at(EffectTiming.Type.TURN_START, 1)
    print("should_expire_at(TURN_START, 1): ", result1)
    if not assert_false(result1):
        print("FAIL: Should not expire at turn 1")
        return false

    var result2 := effect.should_expire_at(EffectTiming.Type.TURN_START, 2)
    print("should_expire_at(TURN_START, 2): ", result2)
    if not assert_true(result2):
        print("FAIL: Should expire at turn 2")
        return false

    # Test wrong timing
    var result3 := effect.should_expire_at(EffectTiming.Type.TURN_END, 2)
    print("should_expire_at(TURN_END, 2): ", result3)
    if not assert_false(result3):
        print("FAIL: Should not expire at wrong timing")
        return false

    print("PASS: TURN_START timing works correctly")
    return true

func test_should_expire_at_with_test_poison_effect() -> bool:
    # Use the exact same TestPoisonEffect from the integration test
    var poison := TestPoisonEffect.new()
    poison.set_expire_timing(EffectTiming.Type.TURN_START)
    poison.set_expire_after_turns(2)

    print("TestPoisonEffect setup:")
    print("  expire_timing (raw): ", poison.get_expire_timing())
    print("  expire_after_turns: ", poison.get_expire_after_turns())
    print("  effect_id: ", poison.get_effect_id())
    print("  effect_name: ", poison.get_effect_name())

    # Test the exact calls from the integration test
    var result1 := poison.should_expire_at(EffectTiming.Type.TURN_START, 1)
    print("poison.should_expire_at(TURN_START, 1): ", result1)
    if not assert_false(result1):
        print("FAIL: Poison should not expire at turn 1")
        return false

    var result2 := poison.should_expire_at(EffectTiming.Type.TURN_START, 2)
    print("poison.should_expire_at(TURN_START, 2): ", result2)
    if not assert_true(result2):
        print("FAIL: Poison should expire at turn 2")
        return false

    print("PASS: TestPoisonEffect should_expire_at works correctly")
    return true

func test_property_persistence_after_application() -> bool:
    # Test if properties are preserved after going through StatusCondition.from_status_effect
    var original_poison := TestPoisonEffect.new()
    original_poison.set_expire_timing(EffectTiming.Type.TURN_START)
    original_poison.set_expire_after_turns(2)

    # Create condition like the real application process does
    var condition := StatusCondition.from_status_effect(original_poison)
    var retrieved_effect := condition.status_effect

    print("Property persistence test:")
    print("  Original effect type: ", original_poison.get_class())
    print("  Retrieved effect type: ", retrieved_effect.get_class())
    print("  Is TimedEffect? ", retrieved_effect is TimedEffect)

    if retrieved_effect is TimedEffect:
        var timed_effect := retrieved_effect as TimedEffect
        print("  Retrieved expire_timing (raw): ", timed_effect.get_expire_timing())
        print("  Retrieved expire_after_turns: ", timed_effect.get_expire_after_turns())

        # Test if should_expire_at still works
        var result := timed_effect.should_expire_at(EffectTiming.Type.TURN_START, 2)
        print("  should_expire_at(TURN_START, 2): ", result)

        if not assert_true(result):
            print("FAIL: Properties not preserved correctly")
            return false
    else:
        print("FAIL: Effect is not TimedEffect after StatusCondition")
        return false

    print("PASS: Properties preserved correctly")
    return true

# Copy of TestPoisonEffect from integration test
class TestPoisonEffect extends TimedEffect:
    func _init() -> void:
        # Initialize with default values that will be overridden in the test
        set_expire_timing(EffectTiming.Type.TURN_END)
        set_expire_after_turns(1)

    func get_effect_id() -> String:
        return "poison"

    func get_effect_name() -> String:
        return "Poison"

    func get_effect_type() -> EffectType:
        return EffectType.NEGATIVE

    func apply_effect(_target: CombatEntity) -> bool:
        return true