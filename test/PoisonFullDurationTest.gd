extends BaseTest
class_name PoisonFullDurationTest

func test_poison_full_duration() -> bool:
    print("=== Testing Poison Full Duration ===")

    # Load poison effect with original 5-turn duration
    var poison := load("res://data/effects/PoisonEffect.tres").duplicate() as ElementalTimedEffect
    print("Poison effect loaded with ", poison.get_expire_after_turns(), " turns")

    # Create a test entity
    var entity: CombatEntity = CombatEntity.new()
    entity._init_combat_entity(100, 10, 5)
    print("Entity created with ", entity.get_current_hp(), " health")

    # Apply poison
    var applied: bool = entity.apply_status_effect(poison)
    print("Poison applied: ", applied)
    print("Has poison: ", entity.has_status_effect("poison"))

    if not applied or not entity.has_status_effect("poison"):
        return false

    # Process all 5 rounds
    for round_num in range(1, 6):
        print("\n--- Round ", round_num, " ---")
        var hp_before: int = entity.get_current_hp()
        entity.process_status_effects_at_timing(EffectTiming.Type.TURN_START, round_num)
        print("Health: ", hp_before, " -> ", entity.get_current_hp())
        print("Has poison: ", entity.has_status_effect("poison"))

        if round_num < 5:
            # Should still have poison
            if not entity.has_status_effect("poison"):
                print("ERROR: Poison should not expire at round ", round_num)
                return false
        else:
            # Should expire after round 5
            if entity.has_status_effect("poison"):
                print("ERROR: Poison should expire after round 5")
                return false

    print("\n✓ Poison correctly lasted 5 rounds and expired")
    return true