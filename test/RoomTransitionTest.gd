extends BaseTest
class_name RoomTransitionTest

func test_room_transition_processing() -> bool:
    print("=== Testing Room Transition Processing ===")

    # Load poison effect
    var poison := load("res://data/effects/PoisonEffect.tres").duplicate() as ElementalTimedEffect
    poison.set_expire_after_turns(3)  # Set to 3 turns for testing
    print("Poison effect set to ", poison.get_expire_after_turns(), " turns")

    # Create a test entity
    var entity: CombatEntity = CombatEntity.new()
    entity._init_combat_entity(100, 10, 5)
    print("Entity created with ", entity.get_current_hp(), " health")

    # Apply poison
    var applied: bool = entity.apply_status_effect(poison)
    print("Poison applied: ", applied)
    print("Has poison: ", entity.has_status_effect("Poison"))

    if not applied or not entity.has_status_effect("Poison"):
        return false

    print("\n--- Processing ALL Timed Effects (Room Transition) ---")
    var hp_before: int = entity.get_current_hp()
    entity.process_all_timed_effects()
    print("Health: ", hp_before, " -> ", entity.get_current_hp())
    print("Has poison: ", entity.has_status_effect("Poison"))

    # Should have taken damage
    if entity.get_current_hp() >= hp_before:
        print("ERROR: Should have taken damage from poison")
        return false

    # Should still have poison (only 1 turn processed)
    if not entity.has_status_effect("Poison"):
        print("ERROR: Should still have poison after 1 turn")
        return false

    print("\n--- Process 2 more room transitions ---")
    for i in range(2):
        print("Room transition ", i + 2, ":")
        hp_before = entity.get_current_hp()
        entity.process_all_timed_effects()
        print("  Health: ", hp_before, " -> ", entity.get_current_hp())
        print("  Has poison: ", entity.has_status_effect("Poison"))

    # After 3 room transitions, poison should be gone
    if entity.has_status_effect("Poison"):
        print("ERROR: Poison should expire after 3 room transitions")
        return false

    print("\n✓ Room transition processing works correctly")
    return true