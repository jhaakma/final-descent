class_name ConstantEffectStackingTest extends BaseTest

func get_test_name() -> String:
    return "ConstantEffectStackingTest"


# Test that consumable effects still show "already affected" message
func test_consumable_effects_dont_stack() -> bool:
    var player := GameState.player

    # Create a simple constant effect (like from a potion)
    var strength_boost := StrengthBoostEffect.new()
    strength_boost.strength_bonus = 2

    # Clear any existing effects
    player.clear_all_status_effects()

    # Apply first effect as consumable (default behavior)
    var condition1 := StatusCondition.from_status_effect(strength_boost)
    player.apply_status_condition(condition1)

    assert_true(player.has_status_effect("strength_boost"), "Should have strength boost from first application")
    var effect_count_after_first := player.status_effect_component.get_effect_count()

    # Try to apply same effect again - should be rejected
    var condition2 := StatusCondition.from_status_effect(strength_boost.duplicate())
    var success := player.apply_status_condition(condition2)

    assert_false(success, "Should reject duplicate consumable effect")
    var effect_count_after_second := player.status_effect_component.get_effect_count()
    assert_equals(effect_count_after_first, effect_count_after_second, "Effect count should be unchanged")

    return true