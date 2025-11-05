class_name StatusEffectTimingIntegrationTest extends BaseTest

# Helper method to create a test player entity
func create_test_player() -> CombatEntity:
    # Create a simple test combat entity
    var entity := TestCombatEntity.new()
    return entity

# Test combat entity class for testing purposes
class TestCombatEntity extends CombatEntity:
    func _init() -> void:
        _init_combat_entity(100, 10, 5)  # Max HP, Attack, Defense

    func get_name() -> String:
        return "Test Entity"

func test_poison_expires_at_round_start() -> bool:
    var player := create_test_player()
    var poison := TestPoisonEffect.new()
    poison.set_expire_timing(EffectTiming.Type.ROUND_START)
    poison.set_expire_after_turns(2)

    player.apply_status_effect(poison)
    if not assert_true(player.has_status_effect("poison")):
        return false

    # Process one round - should still be active
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 1)
    if not assert_true(player.has_status_effect("poison")):
        return false

    # Process second round - should expire
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 2)
    return assert_false(player.has_status_effect("poison"))

func test_defend_expires_at_round_end() -> bool:
    var player := create_test_player()
    var defend := TestDefendEffect.new()
    defend.set_expire_timing(EffectTiming.Type.ROUND_END)
    defend.set_expire_after_turns(1)

    player.apply_status_effect(defend)
    if not assert_true(player.has_status_effect("defend")):
        return false

    # Should not expire during round start
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 1)
    if not assert_true(player.has_status_effect("defend")):
        return false

    # Should expire at round end
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)
    return assert_false(player.has_status_effect("defend"))

func test_multiple_effects_expire_at_different_timings() -> bool:
    var player := create_test_player()

    var poison := TestPoisonEffect.new()
    poison.set_expire_timing(EffectTiming.Type.ROUND_START)
    poison.set_expire_after_turns(1)

    var defend := TestDefendEffect.new()
    defend.set_expire_timing(EffectTiming.Type.ROUND_END)
    defend.set_expire_after_turns(1)

    player.apply_status_effect(poison)
    player.apply_status_effect(defend)

    # Both should be active initially
    if not assert_true(player.has_status_effect("poison")):
        return false
    if not assert_true(player.has_status_effect("defend")):
        return false

    # Poison expires at round start
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 1)
    if not assert_false(player.has_status_effect("poison")):
        return false
    if not assert_true(player.has_status_effect("defend")):
        return false

    # Defend expires at round end
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)
    return assert_false(player.has_status_effect("defend"))

func test_status_effect_component_timing_integration() -> bool:
    var player := create_test_player()

    # Test that status effect component properly handles timing-specific processing
    var effect := TestStunEffect.new()
    effect.set_expire_timing(EffectTiming.Type.ROUND_END)
    effect.set_expire_after_turns(1)

    player.apply_status_effect(effect)

    # Should be active after application
    if not assert_true(player.has_status_effect("stun")):
        return false

    # Should expire when processing ROUND_END timing at turn 1
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)
    return assert_false(player.has_status_effect("stun"))

# Test effect classes that extend the new timing system
class TestPoisonEffect extends TimedEffect:
    func get_effect_id() -> String:
        return "poison"

    func get_effect_name() -> String:
        return "poison"

    func get_effect_type() -> EffectType:
        return EffectType.NEGATIVE

    func apply_effect(_target: CombatEntity) -> bool:
        return true

class TestDefendEffect extends TimedEffect:
    func get_effect_id() -> String:
        return "defend"

    func get_effect_name() -> String:
        return "defend"

    func get_effect_type() -> EffectType:
        return EffectType.POSITIVE

    func apply_effect(_target: CombatEntity) -> bool:
        return true

class TestStunEffect extends TimedEffect:
    func get_effect_id() -> String:
        return "stun"

    func get_effect_name() -> String:
        return "stun"

    func get_effect_type() -> EffectType:
        return EffectType.NEGATIVE

    func apply_effect(_target: CombatEntity) -> bool:
        return true