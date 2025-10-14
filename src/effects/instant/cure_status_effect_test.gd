class_name CureStatusEffectTest extends RefCounted

# Simple test to validate that the cure status effect system works correctly
static func run_test() -> void:
    print("Running CureStatusEffect test...")

    # This is a conceptual test - in practice these would be run in-game
    # Test 1: Verify that CureStatusEffect properly identifies its target
    var poison_condition := load("res://data/effects/conditions/PoisonCondition.tres") as StatusCondition
    var cure_poison := load("res://data/effects/instant/CurePoisonEffect.tres") as CureStatusEffect

    if poison_condition and cure_poison:
        print("✓ Poison condition and cure loaded successfully")
        print("  - Poison condition name: ", poison_condition.name)
        print("  - Cure effect name: ", cure_poison.get_effect_name())
        print("  - Cure effect ID: ", cure_poison.get_effect_id())
        print("  - Cure description: ", cure_poison.get_description())
    else:
        print("✗ Failed to load poison condition or cure effect")

    # Test 2: Verify the condition references the right effect type
    if poison_condition and poison_condition.status_effect is ElementalTimedEffect:
        var elemental_effect := poison_condition.status_effect as ElementalTimedEffect
        print("✓ Poison condition uses ElementalTimedEffect")
        print("  - Damage per turn: ", elemental_effect.damage_per_turn)
        print("  - Duration: ", elemental_effect.duration)
        print("  - Elemental type: ", elemental_effect.elemental_type)
    else:
        print("✗ Poison condition does not use ElementalTimedEffect")

    print("CureStatusEffect test completed.")