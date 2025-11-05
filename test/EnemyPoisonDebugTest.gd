extends BaseTest
class_name EnemyPoisonDebugTest

func test_enemy_poison_in_combat() -> bool:
    print("=== Testing Enemy Poison in Combat ===")

    # Create player and enemy (using concrete test entities)
    var player := TestCombatEntity.new()
    player._init_combat_entity(100, 10, 5)
    player.entity_name = "Player"

    var enemy := TestCombatEntity.new()
    enemy._init_combat_entity(50, 8, 3)
    enemy.entity_name = "Enemy"

    print("Player created: ", player.get_name(), " (", player.get_current_hp(), " HP)")
    print("Enemy created: ", enemy.get_name(), " (", enemy.get_current_hp(), " HP)")

    # Load poison effect
    var poison := load("res://data/effects/PoisonEffect.tres").duplicate() as ElementalTimedEffect
    poison.set_expire_after_turns(3)
    print("Poison loaded: ", poison.get_description())

    # Apply poison to enemy
    print("\n--- Applying Poison to Enemy ---")
    var applied_to_enemy: bool = enemy.apply_status_effect(poison)
    print("Poison applied to enemy: ", applied_to_enemy)
    print("Enemy has poison: ", enemy.has_status_effect("Poison"))

    # Also apply poison to player for comparison
    print("\n--- Applying Poison to Player ---")
    var player_poison := load("res://data/effects/PoisonEffect.tres").duplicate() as ElementalTimedEffect
    player_poison.set_expire_after_turns(3)
    var applied_to_player: bool = player.apply_status_effect(player_poison)
    print("Poison applied to player: ", applied_to_player)
    print("Player has poison: ", player.has_status_effect("Poison"))

    # Simulate combat rounds
    print("\n--- Round 1 Start ---")
    print("Player HP before: ", player.get_current_hp())
    print("Enemy HP before: ", enemy.get_current_hp())

    print("Processing ROUND_START effects...")
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 1)
    enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 1)

    print("Processing ROUND_END effects...")
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)
    enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)

    print("Player HP after round 1: ", player.get_current_hp())
    print("Enemy HP after round 1: ", enemy.get_current_hp())
    print("Player still has poison: ", player.has_status_effect("Poison"))
    print("Enemy still has poison: ", enemy.has_status_effect("Poison"))

    print("\n--- Round 2 Start ---")
    print("Player HP before: ", player.get_current_hp())
    print("Enemy HP before: ", enemy.get_current_hp())

    print("Processing ROUND_START effects...")
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 2)
    enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 2)

    print("Processing ROUND_END effects...")
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 2)
    enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 2)

    print("Player HP after round 2: ", player.get_current_hp())
    print("Enemy HP after round 2: ", enemy.get_current_hp())
    print("Player still has poison: ", player.has_status_effect("Poison"))
    print("Enemy still has poison: ", enemy.has_status_effect("Poison"))

    # Check if both took damage
    var player_took_damage := player.get_current_hp() < 100
    var enemy_took_damage := enemy.get_current_hp() < 50

    print("\n--- Results ---")
    print("Player took poison damage: ", player_took_damage)
    print("Enemy took poison damage: ", enemy_took_damage)

    if not player_took_damage:
        print("ERROR: Player should have taken poison damage")
        return false

    if not enemy_took_damage:
        print("ERROR: Enemy should have taken poison damage")
        return false

    print("✓ Both player and enemy took poison damage correctly")
    return true
