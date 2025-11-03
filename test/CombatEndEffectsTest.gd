extends BaseTest
class_name CombatEndEffectsTest

func test_multiple_effects_on_combat_end() -> bool:
    print("=== Testing Multiple Effects on Combat End ===")

    # Create entities
    var player: CombatEntity = CombatEntity.new()
    player._init_combat_entity(100, 10, 5)

    var enemy: CombatEntity = CombatEntity.new()
    enemy._init_combat_entity(10, 5, 0)

    # Apply poison to both player and enemy
    var poison := load("res://data/effects/PoisonEffect.tres").duplicate() as ElementalTimedEffect
    poison.set_expire_after_turns(3)

    player.apply_status_effect(poison)
    enemy.apply_status_effect(poison)

    print("Initial state:")
    print("  Player HP: ", player.get_current_hp(), ", has poison: ", player.has_status_effect("Poison"))
    print("  Enemy HP: ", enemy.get_current_hp(), ", has poison: ", enemy.has_status_effect("Poison"))

    # Simulate a normal round 1 where both survive
    print("\n--- Round 1 (normal round end) ---")
    var player_hp_before := player.get_current_hp()
    var enemy_hp_before := enemy.get_current_hp()

    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)
    enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)

    print("After round 1:")
    print("  Player HP: ", player_hp_before, " -> ", player.get_current_hp())
    print("  Enemy HP: ", enemy_hp_before, " -> ", enemy.get_current_hp())

    # Now simulate round 2 where enemy dies early but effects should still process
    print("\n--- Round 2 (enemy dies early) ---")
    player_hp_before = player.get_current_hp()
    enemy_hp_before = enemy.get_current_hp()

    # Kill enemy during the round
    enemy.take_damage(20) # Kill the enemy
    print("Enemy killed mid-round")

    # Process ROUND_END effects as combat ends
    print("Processing final ROUND_END effects...")
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 2)
    if enemy.is_alive():  # Only if somehow still alive
        enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 2)

    print("After combat end:")
    print("  Player HP: ", player_hp_before, " -> ", player.get_current_hp())
    print("  Enemy HP: ", enemy_hp_before, " -> ", enemy.get_current_hp(), " (dead)")

    # Verify player took poison damage in both rounds
    if player.get_current_hp() != 98: # Should be 100 - 1 - 1 = 98
        print("ERROR: Player should have 98 HP (took poison damage in both rounds)")
        return false

    print("✓ Effects processed correctly even when combat ends early")
    return true