class_name SimplePoisonTest extends BaseTest

func test_simple_poison() -> bool:
    print("=== Testing Simple Poison ===")

    # Load the actual poison effect resource
    var poison_effect_resource: ElementalTimedEffect = load("res://data/effects/PoisonEffect.tres")
    print("Poison effect loaded: ", poison_effect_resource)
    print("Poison expire timing: ", poison_effect_resource.expire_timing)
    print("Poison expire timing type: ", typeof(poison_effect_resource.expire_timing))

    # Create a combat entity
    var entity: CombatEntity = CombatEntity.new()
    entity._init_combat_entity(100, 10, 5)
    print("Entity created with ", entity.get_current_hp(), " health")

    # Apply poison
    var applied: bool = entity.apply_status_effect(poison_effect_resource)
    print("Poison applied: ", applied)
    print("Has poison: ", entity.has_status_effect("Poison"))

    if not assert_true(applied):
        return false
    if not assert_true(entity.has_status_effect("Poison")):
        return false    # Test processing at round end (where poison should tick)
    print("\n--- Processing at ROUND_END timing ---")
    var initial_health: int = entity.get_current_hp()
    entity.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 1)
    print("Health after round 1: ", entity.get_current_hp())

    # Poison should have dealt damage
    if not assert_true(entity.get_current_hp() < initial_health):
        return false

    var health_after_round_1: int = entity.get_current_hp()
    entity.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, 2)
    print("Health after round 2: ", entity.get_current_hp())

    # Poison should have dealt damage again
    if not assert_true(entity.get_current_hp() < health_after_round_1):
        return false

    print("=== Test Complete ===")
    return true