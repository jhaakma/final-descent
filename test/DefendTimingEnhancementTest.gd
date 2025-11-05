class_name DefendTimingEnhancementTest extends BaseTest

# Test to verify defend effect timing with TURN_START expiration
func test_defend_effect_turn_start_timing() -> bool:
    print("=== Testing Defend Effect TURN_START Timing ===")

    # Create a player
    var player := Player.new()

    # Create a defend effect
    var defend_effect := DefendEffect.new(50)
    print("Defend effect expire timing: ", defend_effect.get_expire_timing())
    print("Expected TURN_START (1): ", EffectTiming.Type.TURN_START)

    # Verify timing is set correctly
    if not assert_equals(defend_effect.get_expire_timing(), EffectTiming.Type.TURN_START, "DefendEffect should expire at TURN_START"):
        return false

    # Apply defend effect
    var applied := player.apply_status_effect(defend_effect)
    if not assert_true(applied, "Defend effect should be applied"):
        return false

    if not assert_true(player.has_status_effect("defend"), "Player should have defend effect"):
        return false

    print("\n--- Processing ROUND_START (should not expire) ---")
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 1)
    if not assert_true(player.has_status_effect("defend"), "Defend effect should persist after ROUND_START"):
        return false

    print("--- Processing TURN_START round 1 (should not expire yet) ---")
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)
    if not assert_true(player.has_status_effect("defend"), "Defend effect should persist through first TURN_START"):
        return false

    print("--- Processing TURN_START round 2 (should expire) ---")
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 2)
    if not assert_false(player.has_status_effect("defend"), "Defend effect should expire on second TURN_START"):
        return false

    print("✓ Defend effect TURN_START timing test passed")
    return true

func test_defend_effect_persists_through_enemy_turn() -> bool:
    print("=== Testing Defend Effect Persists Through Enemy Turn ===")

    # Create player and enemy
    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 50
    enemy_resource.attack = 8
    enemy_resource.defense = 3
    var enemy := Enemy.new(enemy_resource)

    # Create combat context and state manager
    var context := CombatContext.new(player, enemy, enemy_resource)
    var combat_manager := CombatStateManager.new(context)

    # Apply defend effect to player
    var defend_effect := DefendEffect.new(50)
    if not assert_true(player.apply_status_effect(defend_effect), "Defend effect should be applied"):
        return false

    print("Player has defend effect initially: ", player.has_status_effect("defend"))

    # Start combat - this processes ROUND_START effects
    combat_manager.start_combat()
    if not assert_true(player.has_status_effect("defend"), "Defend should persist after combat start"):
        return false

    # Player's turn starts - this should NOT expire defend effect on round 1
    if combat_manager.get_current_state() == CombatStateManager.State.PLAYER_TURN:
        print("Player turn started - defend should still be active")
        if not assert_true(player.has_status_effect("defend"), "Defend should be active during player's turn"):
            return false

    # End player turn and move to enemy turn
    combat_manager.end_current_turn()

    # Enemy turn starts - defend should still be active
    if combat_manager.get_current_state() == CombatStateManager.State.ENEMY_TURN:
        print("Enemy turn started - defend should still be active")
        if not assert_true(player.has_status_effect("defend"), "Defend should persist during enemy turn"):
            return false

    # End enemy turn (this should complete round 1)
    combat_manager.end_current_turn()

    # Round 2 should start with player turn - defend should now expire
    if combat_manager.get_current_state() == CombatStateManager.State.PLAYER_TURN:
        print("Round 2 player turn - defend should now be expired")
        if not assert_false(player.has_status_effect("defend"), "Defend should expire at start of next player turn"):
            return false

    print("✓ Defend effect persists through enemy turn test passed")
    return true

func test_defend_effect_ui_visibility() -> bool:
    print("=== Testing Defend Effect UI Visibility ===")

    # Create a player
    var player := Player.new()

    # Apply defend effect
    var defend_effect := DefendEffect.new(50)
    if not assert_true(player.apply_status_effect(defend_effect), "Defend effect should be applied"):
        return false

    # Check that the effect is visible in status effects
    var effects_description: String = player.get_status_effects_description()
    if not assert_string_contains(effects_description, "DEF", "Status effects should show defense bonus"):
        return false

    if not assert_string_contains(effects_description, "defending", "Status effects should show defending state"):
        return false

    # Verify defense bonus is applied
    var initial_defense := player.get_base_defense()
    var total_defense := player.get_total_defense()
    if not assert_true(total_defense > initial_defense, "Total defense should be higher than base defense"):
        return false

    print("Player base defense: ", initial_defense)
    print("Player total defense with defend: ", total_defense)
    print("Defense bonus: ", total_defense - initial_defense)

    print("✓ Defend effect UI visibility test passed")
    return true