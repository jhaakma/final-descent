class_name PropertyTest extends BaseTest

# Test the timing property setters and getters in isolation
func test_timing_property_basic() -> bool:
    var effect := TimedEffect.new()

    print("=== TIMING PROPERTY TEST ===")
    print("Default expire_timing: ", effect.expire_timing)
    print("Default expire_after_turns: ", effect.expire_after_turns)

    # Test getter methods
    var timing := effect.get_expire_timing()
    print("get_expire_timing(): ", timing)
    var turns := effect.get_expire_after_turns()
    print("get_expire_after_turns(): ", turns)

    # Test setter methods
    effect.set_expire_timing(EffectTiming.Type.TURN_START)
    print("After set_expire_timing(TURN_START):")
    print("  expire_timing: ", effect.expire_timing)
    print("  get_expire_timing(): ", effect.get_expire_timing())

    effect.set_expire_after_turns(2)
    print("After set_expire_after_turns(2):")
    print("  expire_after_turns: ", effect.expire_after_turns)
    print("  get_expire_after_turns(): ", effect.get_expire_after_turns())

    return true

func test_effect_timing_enum_values() -> bool:
    print("=== ENUM VALUES TEST ===")
    print("TURN_START: ", EffectTiming.Type.TURN_START)
    print("ROUND_END: ", EffectTiming.Type.ROUND_END)

    # Verify the enum values are as expected
    if EffectTiming.Type.TURN_START != 1:
        print("ERROR: TURN_START should be 1, got: ", EffectTiming.Type.TURN_START)
        return false

    if EffectTiming.Type.ROUND_END != 2:
        print("ERROR: ROUND_END should be 2, got: ", EffectTiming.Type.ROUND_END)
        return false

    return true

func test_should_expire_at_minimal() -> bool:
    var effect := TimedEffect.new()

    print("=== MINIMAL SHOULD_EXPIRE_AT TEST ===")

    # Test with default values first (default is ROUND_END, expire_after_turns = 1)
    var result1 := effect.should_expire_at(EffectTiming.Type.ROUND_END, 1)
    print("Default should_expire_at(ROUND_END, 1): ", result1)
    if not result1:
        print("ERROR: Default case should return true")
        return false

    # Now test changing timing
    effect.expire_timing = EffectTiming.Type.TURN_START
    effect.expire_after_turns = 2
    print("Modified properties directly:")
    print("  expire_timing: ", effect.expire_timing)
    print("  expire_after_turns: ", effect.expire_after_turns)

    var result2 := effect.should_expire_at(EffectTiming.Type.TURN_START, 2)
    print("Modified should_expire_at(TURN_START, 2): ", result2)
    if not result2:
        print("ERROR: Modified case should return true")
        return false

    return true