class_name SimplePoisonTest extends BaseTest

func test_simple_poison() -> bool:
    print("=== Testing Simple Poison ===")

    # Load the actual poison effect resource
    var poison_effect_resource: ElementalTimedEffect = load("res://data/effects/PoisonEffect.tres")
    print("Poison effect loaded: ", poison_effect_resource)

    # Create a combat entity
    var entity: CombatEntity = CombatEntity.new()
    entity._init_combat_entity(100, 10, 5)
    print("Entity created with ", entity.get_current_hp(), " health")

    # Apply poison
    var applied: bool = entity.apply_status_effect(poison_effect_resource)
    print("Poison applied: ", applied)
    print("Has poison: ", entity.has_status_effect("poison"))

    if not assert_true(applied):
        return false
    if not assert_true(entity.has_status_effect("poison")):
        return false    # Test processing at turn start (where poison should tick)
    print("\n--- Processing at TURN_START timing ---")
    var initial_health: int = entity.get_current_hp()
    entity.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)
    print("Health after round 1: ", entity.get_current_hp())

    # Poison should have dealt damage
    if not assert_true(entity.get_current_hp() < initial_health):
        return false

    var health_after_round_1: int = entity.get_current_hp()
    entity.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 2)
    print("Health after round 2: ", entity.get_current_hp())

    # Poison should have dealt damage again
    if not assert_true(entity.get_current_hp() < health_after_round_1):
        return false

    print("=== Test Complete ===")
    return true