class_name EffectTimingTest extends BaseTest

func test_effect_timing_enum_has_all_phases() -> bool:
    # Test our enhanced 4-phase timing system
    var expected_phases: Array[String] = ["ROUND_START", "TURN_START", "TURN_END", "ROUND_END"]
    for phase in expected_phases:
        if not EffectTiming.has(phase):
            return false
    return true

func test_timing_phases_have_correct_values() -> bool:
    # Ensure enum values are assigned correctly for our 4-phase system
    return assert_equals(EffectTiming.Type.ROUND_START, 0) and \
           assert_equals(EffectTiming.Type.TURN_START, 1) and \
           assert_equals(EffectTiming.Type.ROUND_END, 3)

func test_timing_phases_are_ordered_correctly() -> bool:
    # Verify that our enhanced timing phases follow logical chronological order
    return assert_true(EffectTiming.Type.ROUND_START < EffectTiming.Type.TURN_START) and \
           assert_true(EffectTiming.Type.TURN_START < EffectTiming.Type.ROUND_END)