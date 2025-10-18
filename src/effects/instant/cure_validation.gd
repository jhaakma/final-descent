extends Node

# Small validation script to test our cure system
func _ready() -> void:
    test_cure_system()

func test_cure_system() -> void:
    print("Testing CureStatusEffect refactor...")

    # Load the resources
    var poison_condition := load("res://data/effects/conditions/PoisonCondition.tres") as StatusCondition
    var cure_poison := load("res://data/effects/instant/CurePoisonEffect.tres") as CureStatusEffect

    if not poison_condition:
        print("ERROR: Failed to load PoisonCondition")
        return

    if not cure_poison:
        print("ERROR: Failed to load CurePoisonEffect")
        return

    print("✓ Successfully loaded both resources")
    print("  Poison condition name: ", poison_condition.name)
    print("  Cure effect name: ", cure_poison.get_effect_name())
    print("  Cure targets: ", cure_poison.condition_to_cure if cure_poison.condition_to_cure else "null")

    # Verify the poison condition uses ElementalTimedEffect
    if poison_condition.status_effect is ElementalTimedEffect:
        var elemental_effect := poison_condition.status_effect as ElementalTimedEffect
        print("✓ Poison condition uses ElementalTimedEffect correctly")
        print("  Damage per turn: ", elemental_effect.damage_per_turn)
        print("  Duration: ", elemental_effect.duration)
        print("  Type: ", elemental_effect.elemental_type)
    else:
        print("ERROR: Poison condition doesn't use ElementalTimedEffect")

    print("Cure system validation complete!")