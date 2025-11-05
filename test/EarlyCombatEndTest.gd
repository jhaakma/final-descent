extends BaseTest
class_name EarlyCombatEndTest

func test_poison_on_early_combat_end() -> bool:
    print("=== Testing Poison on Early Combat End ===")

    # Load poison effect with short duration for testing
    var poison := load("res://data/effects/PoisonEffect.tres").duplicate() as ElementalTimedEffect
    poison.set_expire_after_turns(2)
    print("Poison effect set to ", poison.get_expire_after_turns(), " turns")

    # Create a test player
    var player: CombatEntity = CombatEntity.new()
    player._init_combat_entity(100, 10, 5)
    print("Player created with ", player.get_current_hp(), " health")

    # Create a weak enemy that will die in one hit
    var enemy: CombatEntity = CombatEntity.new()
    enemy._init_combat_entity(1, 5, 0)  # 1 HP, dies immediately
    print("Enemy created with ", enemy.get_current_hp(), " health")

    # Apply poison to player
    var applied: bool = player.apply_status_effect(poison)
    print("Poison applied to player: ", applied)
    print("Player has poison: ", player.has_status_effect("poison"))

    if not applied or not player.has_status_effect("poison"):
        return false

    print("\n--- Simulating Combat Round 1 ---")
    # Player's first turn - attack enemy to kill it
    var initial_hp: int = player.get_current_hp()
    print("Player initial HP: ", initial_hp)

    # Kill the enemy (simulating player attack)
    enemy.take_damage(10)  # More than enough to kill 1 HP enemy
    print("Enemy killed - HP: ", enemy.get_current_hp(), ", alive: ", enemy.is_alive())

    # Now simulate combat ending early due to enemy death
    # We should process TURN_START effects manually (simulating player's turn)
    print("\n--- Simulating Early Combat End with TURN_START Processing ---")

    # Directly process TURN_START effects (poison ticks at turn start)
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)

    print("Player HP after combat end: ", player.get_current_hp())
    print("Player still has poison: ", player.has_status_effect("poison"))

    # Player should have taken poison damage even though combat ended early
    if player.get_current_hp() >= initial_hp:
        print("ERROR: Player should have taken poison damage during early combat end")
        return false

    print("✓ Poison damage applied correctly during early combat end")
    return true
