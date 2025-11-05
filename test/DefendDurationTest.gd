class_name DefendDurationTest extends BaseTest

# Test to verify defend effect timing

func test_defend_effect_timing() -> bool:
    print("Testing defend effect timing with proper combat simulation...")

    # Create player and enemy
    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 50
    enemy_resource.attack = 8
    enemy_resource.defense = 3

    var enemy := Enemy.new(enemy_resource)

    # Create defend ability for enemy
    var defend_ability := DefendAbility.new()
    var defend_instance := AbilityInstance.new(defend_ability)
    enemy.ability_instances = [defend_instance]

    print("=== Turn 1: Enemy defends ===")
    # Enemy defends
    enemy.process_status_effects()  # Start of enemy turn
    defend_instance.execute(enemy, player)
    print("Enemy has defend effect: %s" % enemy.has_status_effect("defend"))

    print("=== Turn 2: Player attacks (should be defended) ===")
    # Player attacks - defend should be active
    player.process_status_effects()  # Start of player turn
    var enemy_defense_before := enemy.get_total_defense()
    var enemy_base_defense := enemy.get_base_defense()
    print("Enemy base defense: %d" % enemy_base_defense)
    print("Enemy total defense before attack: %d" % enemy_defense_before)
    print("Enemy defense bonus: %d" % (enemy_defense_before - enemy_base_defense))
    if not assert_true(enemy.has_status_effect("defend"), "Enemy should have defend effect during turn 2"):
        return false

    # Simulate player attack
    var damage := 10
    var final_damage := enemy.calculate_incoming_damage(damage)
    print("Attack damage: %d, final damage after defense: %d" % [damage, final_damage])
    print("Expected damage with 53%% defense: %d" % int(damage * (1.0 - 0.53)))

    # Process POST_ACTION timing to expire defend effect after attack
    enemy.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 2)

    print("=== Turn 3: Enemy turn (defend should expire) ===")
    # Enemy's next turn - defend should expire
    enemy.process_status_effects()  # Start of enemy turn - this should expire defend
    print("Enemy has defend effect after processing: %s" % enemy.has_status_effect("defend"))

    # Reset ability state (simulate normal combat flow)
    enemy._reduce_ability_cooldowns()

    print("=== Turn 4: Player attacks again (should NOT be defended) ===")
    # Player attacks again - defend should be gone
    player.process_status_effects()  # Start of player turn
    var enemy_defense_after := enemy.get_total_defense()
    print("Enemy defense after defend expired: %d" % enemy_defense_after)
    if not assert_false(enemy.has_status_effect("defend"), "Defend effect should have expired by turn 4"):
        return false

    # Simulate second player attack
    var final_damage_2 := enemy.calculate_incoming_damage(damage)
    print("Second attack damage: %d, final damage: %d" % [damage, final_damage_2])

    # Verify that first attack was defended but second was not
    if not assert_true(final_damage < final_damage_2, "First attack (%d) should have been more defended than second attack (%d)" % [final_damage, final_damage_2]):
        return false

    print("✓ Defend effect timing test passed")
    return true