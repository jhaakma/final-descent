class_name EffectTimingTest extends BaseTest

func test_effect_timing_enum_has_all_phases() -> bool:
    # Test our simplified 3-phase timing system
    var expected_phases: Array[String] = ["ROUND_START", "TURN_END", "ROUND_END"]
    for phase in expected_phases:
        if not EffectTiming.has(phase):
            return false
    return true

func test_timing_phases_have_correct_values() -> bool:
    # Ensure enum values are assigned correctly for our 3-phase system
    return assert_equals(EffectTiming.Type.ROUND_START, 0) and \
           assert_equals(EffectTiming.Type.TURN_END, 1) and \
           assert_equals(EffectTiming.Type.ROUND_END, 2)

func test_timing_phases_are_ordered_correctly() -> bool:
    # Verify that our simplified timing phases follow logical chronological order
    return assert_true(EffectTiming.Type.ROUND_START < EffectTiming.Type.TURN_END) and \
           assert_true(EffectTiming.Type.TURN_END < EffectTiming.Type.ROUND_END)