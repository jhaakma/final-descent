class_name TimedEffectEnhancementTest extends BaseTest

func test_timed_effect_has_timing_properties() -> bool:
    # This test will pass now that TimedEffect has timing properties
    var effect = TimedEffect.new()
    return assert_has_method(effect, "get_expire_timing") and \
           assert_has_method(effect, "get_expire_after_turns") and \
           assert_has_method(effect, "get_expire_condition") and \
           assert_has_method(effect, "set_expire_timing") and \
           assert_has_method(effect, "set_expire_after_turns") and \
           assert_has_method(effect, "set_expire_condition")

func test_timed_effect_defaults() -> bool:
    var effect = TimedEffect.new()
    var condition = effect.get_expire_condition()
    return assert_equals(effect.get_expire_timing(), EffectTiming.Type.ROUND_END) and \
           assert_equals(effect.get_expire_after_turns(), 1) and \
           assert_false(condition.is_valid())

func test_should_expire_at_correct_timing() -> bool:
    var effect = TimedEffect.new()
    effect.set_expire_timing(EffectTiming.Type.ROUND_START)
    effect.set_expire_after_turns(2)

    # Should not expire at wrong timing
    var wrong_timing_result = effect.should_expire_at(EffectTiming.Type.ROUND_END, 2)
    if not assert_false(wrong_timing_result):
        return false

    # Should not expire before turn count reached
    var early_turn_result = effect.should_expire_at(EffectTiming.Type.ROUND_START, 1)
    if not assert_false(early_turn_result):
        return false

    # Should expire at correct timing and turn
    var correct_result = effect.should_expire_at(EffectTiming.Type.ROUND_START, 2)
    return assert_true(correct_result)

func test_custom_expire_condition_works() -> bool:
    var effect = TimedEffect.new()
    var test_tracker = {"called": false}
    var condition_func = func() -> bool:
        test_tracker["called"] = true
        return true
    effect.set_expire_condition(condition_func)

    var should_expire: bool = effect.should_expire_at(EffectTiming.Type.ROUND_END, 1)
    return assert_true(test_tracker["called"]) and assert_true(should_expire)

func test_expire_condition_overrides_turn_count() -> bool:
    var effect = TimedEffect.new()
    effect.set_expire_after_turns(5)  # Set high turn count

    # Condition returns false - should not expire even if turn count reached
    var false_condition = func() -> bool: return false
    effect.set_expire_condition(false_condition)

    var should_not_expire: bool = effect.should_expire_at(EffectTiming.Type.ROUND_END, 5)
    return assert_false(should_not_expire)

func test_expire_timing_validation() -> bool:
    var effect = TimedEffect.new()

    # Test setting valid timing values
    effect.set_expire_timing(EffectTiming.Type.ROUND_END)
    var timing_result: EffectTiming.Type = effect.get_expire_timing()
    if not assert_equals(timing_result, EffectTiming.Type.ROUND_END):
        return false

    effect.set_expire_timing(EffectTiming.Type.ROUND_END)
    timing_result = effect.get_expire_timing()
    return assert_equals(timing_result, EffectTiming.Type.ROUND_END)