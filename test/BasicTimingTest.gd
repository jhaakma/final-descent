class_name BasicTimingTest extends BaseTest

# Test combat entity class for testing purposes
class TestCombatEntity extends CombatEntity:
    func _init() -> void:
        _init_combat_entity(100, 10, 5)  # Max HP, Attack, Defense

    func get_name() -> String:
        return "Test Entity"

# Test effect class
class TestEffect extends TimedEffect:
    func _init() -> void:
        set_expire_timing(EffectTiming.Type.TURN_START)
        set_expire_after_turns(1)

    func get_effect_id() -> String:
        return "test_effect"

    func get_effect_name() -> String:
        return "Test Effect"

    func get_effect_type() -> EffectType:
        return EffectType.NEUTRAL

    func apply_effect(_target: CombatEntity) -> bool:
        return true

func test_basic_effect_application() -> bool:
    var entity := TestCombatEntity.new()
    var effect := TestEffect.new()

    # Apply the effect
    var applied := entity.apply_status_effect(effect)
    if not assert_true(applied):
        return false

    # Check that the effect is active
    var has_effect := entity.has_status_effect("test_effect")
    return assert_true(has_effect)

func test_basic_timing_expiration() -> bool:
    var entity := TestCombatEntity.new()
    var effect := TestEffect.new()

    # Apply the effect
    entity.apply_status_effect(effect)

    # Verify it's active
    if not assert_true(entity.has_status_effect("test_effect")):
        return false

    # Process timing at TURN_START with turn 1 - should expire
    entity.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)

    # Should be gone now
    return assert_false(entity.has_status_effect("test_effect"))