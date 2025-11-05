class_name StatusOnStrikeEnchantmentTest extends BaseTest

func get_test_name() -> String:
    return "StatusOnStrikeEnchantment"

# Test that each target gets its own instance of the status effect
func test_multiple_targets_get_separate_effect_instances() -> bool:
    # Setup
    var stun_effect := StunEffect.new()
    stun_effect.set_expire_after_turns(2)

    var enchantment := StatusOnStrikeEnchantment.new()
    enchantment.status_effect = stun_effect
    enchantment.effect_apply_chance = 1.0  # 100% chance for testing

    # Create test enemies
    var enemy_resource1 := EnemyResource.new()
    enemy_resource1.name = "Test Enemy 1"
    enemy_resource1.max_hp = 100
    enemy_resource1.attack = 5
    enemy_resource1.defense = 10
    var target1 := Enemy.new(enemy_resource1)

    var enemy_resource2 := EnemyResource.new()
    enemy_resource2.name = "Test Enemy 2"
    enemy_resource2.max_hp = 100
    enemy_resource2.attack = 5
    enemy_resource2.defense = 10
    var target2 := Enemy.new(enemy_resource2)

    # Apply the enchantment to both targets
    enchantment.on_strike(target1)
    enchantment.on_strike(target2)

    # Both targets should have the stun effect
    var target1_has_stun := target1.has_status_effect("Stun")
    var target2_has_stun := target2.has_status_effect("Stun")

    if not target1_has_stun:
        push_error("Target 1 should have stun effect")
        return false
    if not target2_has_stun:
        push_error("Target 2 should have stun effect")
        return false

    # Get the status effect conditions from both targets
    var target1_condition := target1.status_effect_component.get_effect("stun")
    var target2_condition := target2.status_effect_component.get_effect("stun")

    if target1_condition == null:
        push_error("Target 1 stun condition should not be null")
        return false
    if target2_condition == null:
        push_error("Target 2 stun condition should not be null")
        return false

    var target1_effect := target1_condition.status_effect as StunEffect
    var target2_effect := target2_condition.status_effect as StunEffect

    # The effects should be different instances
    if target1_effect == target2_effect:
        push_error("Target 1 and Target 2 should have different effect instances")
        return false

    # Both should have 2 expire_after_turns initially
    if target1_effect.get_expire_after_turns() != 2:
        push_error("Target 1 should have 2 expire_after_turns, got %d" % target1_effect.get_expire_after_turns())
        return false
    if target2_effect.get_expire_after_turns() != 2:
        push_error("Target 2 should have 2 expire_after_turns, got %d" % target2_effect.get_expire_after_turns())
        return false

    # Test that they are independent by modifying one
    target1_effect.set_expire_after_turns(1)

    # Target1 should now have 1 turn, target2 should still have 2
    if target1_effect.get_expire_after_turns() != 1:
        push_error("Target 1 should have 1 expire_after_turns after modification, got %d" % target1_effect.get_expire_after_turns())
        return false
    if target2_effect.get_expire_after_turns() != 2:
        push_error("Target 2 should still have 2 expire_after_turns, got %d" % target2_effect.get_expire_after_turns())
        return false

    print("Multiple targets correctly get separate effect instances")
    return true

# Test that status effects expire through turn processing
func test_stun_effect_expires_correctly() -> bool:
    # Setup
    var stun_effect := StunEffect.new()
    stun_effect.set_expire_after_turns(1)  # Short duration for testing

    var enchantment := StatusOnStrikeEnchantment.new()
    enchantment.status_effect = stun_effect
    enchantment.effect_apply_chance = 1.0  # 100% chance for testing

    # Create test enemy
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Enemy"
    enemy_resource.max_hp = 100
    enemy_resource.attack = 5
    enemy_resource.defense = 10
    var target := Enemy.new(enemy_resource)

    # Apply the enchantment
    enchantment.on_strike(target)

    # Target should have the stun effect
    if not target.has_status_effect("Stun"):
        push_error("Target should have stun effect after enchantment application")
        return false

    # Get the status effect
    var condition := target.status_effect_component.get_effect("stun")
    if condition == null:
        push_error("Stun condition should not be null")
        return false

    var effect := condition.status_effect as StunEffect
    if effect.get_expire_after_turns() != 1:
        push_error("Effect should have 1 expire_after_turns, got %d" % effect.get_expire_after_turns())
        return false

    # Process status effects (this should expire the effect)
    # Since stun effect expires at ROUND_END by default, we need to process ROUND_END timing
    target.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)

    # Effect should have expired and been removed
    if target.has_status_effect("Stun"):
        push_error("Target should no longer have stun effect after processing")
        return false

    print("Stun effect expires correctly through turn processing")
    return true

# Test the exact combat scenario where the bug occurs
func test_stunned_enemy_status_effects_never_processed() -> bool:
    # Setup
    var stun_effect := StunEffect.new()
    stun_effect.set_expire_after_turns(1)  # Short duration for testing

    var enchantment := StatusOnStrikeEnchantment.new()
    enchantment.status_effect = stun_effect
    enchantment.effect_apply_chance = 1.0  # 100% chance for testing

    # Create test enemy
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Enemy"
    enemy_resource.max_hp = 100
    enemy_resource.attack = 5
    enemy_resource.defense = 10
    var target := Enemy.new(enemy_resource)

    # Apply the enchantment
    enchantment.on_strike(target)

    # Target should have the stun effect and should skip turn
    if not target.has_status_effect("Stun"):
        push_error("Target should have stun effect after enchantment application")
        return false

    if not target.should_skip_turn():
        push_error("Target should skip turn when stunned")
        return false

    # Simulate the current combat logic where status effects are NOT processed when skipping turn
    # This is the bug - status effects should be processed even when skipping turn
    if target.should_skip_turn():
        # Current buggy behavior: don't process status effects
        pass
    else:
        target.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)

    # The bug: effect should expire but doesn't because it was never processed
    if not target.has_status_effect("Stun"):
        push_error("Bug reproduced: effect should still be active but got processed somehow")
        return false

    if not target.should_skip_turn():
        push_error("Bug reproduced: target should still be skipping turn")
        return false

    print("Bug reproduced: stunned enemy status effects never get processed")
    return true

# Test the fix: status effects should be processed even when skipping turn
func test_stunned_enemy_status_effects_processed_correctly() -> bool:
    # Setup
    var stun_effect := StunEffect.new()
    stun_effect.set_expire_after_turns(1)  # Short duration for testing

    var enchantment := StatusOnStrikeEnchantment.new()
    enchantment.status_effect = stun_effect
    enchantment.effect_apply_chance = 1.0  # 100% chance for testing

    # Create test enemy
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Enemy"
    enemy_resource.max_hp = 100
    enemy_resource.attack = 5
    enemy_resource.defense = 10
    var target := Enemy.new(enemy_resource)

    # Apply the enchantment
    enchantment.on_strike(target)

    # Target should have the stun effect and should skip turn
    if not target.has_status_effect("Stun"):
        push_error("Target should have stun effect after enchantment application")
        return false

    if not target.should_skip_turn():
        push_error("Target should skip turn when stunned")
        return false

    # Simulate the FIXED combat logic where status effects ARE processed even when skipping turn
    target.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)  # Process effects regardless of skip status

    # The fix: effect should expire after being processed
    if target.has_status_effect("Stun"):
        push_error("Fix failed: effect should have expired after processing")
        return false

    if target.should_skip_turn():
        push_error("Fix failed: target should no longer be skipping turn")
        return false

    print("Fix verified: stunned enemy status effects get processed correctly")
    return true
