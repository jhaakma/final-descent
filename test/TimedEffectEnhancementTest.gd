class_name TimedEffectEnhancementTest extends BaseTest


func test_should_expire_at_correct_timing() -> bool:
    var effect := TestTimedEffect.new()
    effect.set_expire_timing(EffectTiming.Type.ROUND_START)
    effect.set_expire_after_turns(2)

    # Should not expire at wrong timing
    var wrong_timing_result := effect.should_expire_at(EffectTiming.Type.ROUND_END, 2)
    if not assert_false(wrong_timing_result):
        return false

    # Should not expire before turn count reached
    var early_turn_result := effect.should_expire_at(EffectTiming.Type.ROUND_START, 1)
    if not assert_false(early_turn_result):
        return false

    # Should expire at correct timing and turn
    var correct_result := effect.should_expire_at(EffectTiming.Type.ROUND_START, 2)
    return assert_true(correct_result)

func test_expire_timing_validation() -> bool:
    var effect := TimedEffect.new()

    # Test setting valid timing values
    effect.set_expire_timing(EffectTiming.Type.ROUND_END)
    var timing_result: EffectTiming.Type = effect.get_expire_timing()
    if not assert_equals(timing_result, EffectTiming.Type.ROUND_END):
        return false

    effect.set_expire_timing(EffectTiming.Type.ROUND_END)
    timing_result = effect.get_expire_timing()
    return assert_equals(timing_result, EffectTiming.Type.ROUND_END)

class TestTimedEffect extends TimedEffect:

    var expire_timing: EffectTiming.Type = EffectTiming.Type.TURN_START

    func get_effect_id() -> String:
        return "poison"

    func get_effect_name() -> String:
        return "Poison"

    func get_effect_type() -> EffectType:
        return EffectType.NEGATIVE

    func apply_effect(_target: CombatEntity) -> bool:
        return true

    func get_expire_timing() -> EffectTiming.Type:
        return expire_timing

    func set_expire_timing(timing: EffectTiming.Type) -> void:
        expire_timing = timing
