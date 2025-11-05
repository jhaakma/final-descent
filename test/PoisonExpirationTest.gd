extends BaseTest
class_name PoisonExpirationTest

func test_poison_expiration() -> bool:
    print("=== Testing Poison Expiration ===")

    # Load poison effect
    var poison := load("res://data/effects/PoisonEffect.tres").duplicate() as ElementalTimedEffect
    print("Poison effect loaded: ", poison)

    # Set it to expire after just 2 turns for testing
    poison.set_expire_after_turns(2)
    print("Poison set to 2 turns")

    # Create a test entity
    var entity: CombatEntity = CombatEntity.new()
    entity._init_combat_entity(100, 10, 5)
    print("Entity created with ", entity.get_current_hp(), " health")

    # Apply poison
    var applied: bool = entity.apply_status_effect(poison)
    print("Poison applied: ", applied)

    # Verify it was applied
    var has_poison: bool = entity.has_status_effect("poison")
    print("Has poison: ", has_poison)

    if not has_poison:
        return false

    print("\n--- Processing Round 1 ---")
    entity.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)
    print("Health after round 1: ", entity.get_current_hp())
    print("Still has poison: ", entity.has_status_effect("poison"))

    if not entity.has_status_effect("poison"):
        print("ERROR: Poison should not expire after 1 round")
        return false

    print("\n--- Processing Round 2 ---")
    entity.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 2)
    print("Health after round 2: ", entity.get_current_hp())
    print("Still has poison: ", entity.has_status_effect("poison"))

    # After 2 rounds, poison should be expired
    if entity.has_status_effect("poison"):
        print("ERROR: Poison should expire after 2 rounds")
        return false

    print("✓ Poison correctly expired after 2 rounds")
    return true