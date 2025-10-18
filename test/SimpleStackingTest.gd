extends BaseTest

func get_test_name() -> String:
    return "SimpleStackingTest"

# Simple test to see what's happening with constant effect stacking
func test_basic_stacking_debug() -> bool:
    var player := GameState.player

    # Clear everything first
    player.clear_all_status_effects()

    # Create a simple fire resistance effect
    var fire_resistance := ElementalResistanceEffect.new()
    fire_resistance.elemental_type = DamageType.Type.FIRE

    print("=== Testing Equipment-Based Effect Application ===")

    # Test 1: Apply as equipment effect
    var condition1 := StatusCondition.from_equipment_effect(fire_resistance, "Test Armor 1")
    print("Created condition1 with source_type: ", condition1.source_type)
    print("Equipment sources: ", condition1.equipment_sources)

    var success1 := player.apply_status_condition(condition1)
    print("First application success: ", success1)
    print("Player has fire resistance: ", player.has_status_effect("fire_resistance"))
    print("Active conditions count: ", player.status_effect_component.active_conditions.size())

    # Check the condition before adding second
    var active_condition_before := player.status_effect_component.get_effect("fire_resistance")
    if active_condition_before:
        print("Before second: equipment sources: ", active_condition_before.equipment_sources)

    # Test 2: Apply another equipment effect with same type
    var condition2 := StatusCondition.from_equipment_effect(fire_resistance.duplicate(), "Test Armor 2")
    print("\n--- Applying Second Equipment Effect ---")
    print("condition2 source_id: ", condition2.source_id)
    print("condition2 equipment_sources: ", condition2.equipment_sources)

    var success2 := player.apply_status_condition(condition2)
    print("Second application success: ", success2)
    print("Active conditions count: ", player.status_effect_component.active_conditions.size())

    # Check the condition details
    var active_condition := player.status_effect_component.get_effect("fire_resistance")
    if active_condition:
        print("After second: equipment sources: ", active_condition.equipment_sources)
        print("Source type: ", active_condition.source_type)
    else:
        print("No active fire resistance condition found!")

    # Test 3: Remove first equipment source
    print("\n--- Removing First Equipment Source ---")
    player.remove_equipment_source(fire_resistance, "Test Armor 1")
    print("Player still has fire resistance: ", player.has_status_effect("fire_resistance"))

    active_condition = player.status_effect_component.get_effect("fire_resistance")
    if active_condition:
        print("After removing first: equipment sources: ", active_condition.equipment_sources)

    # Test 4: Remove second equipment source
    print("\n--- Removing Second Equipment Source ---")
    player.remove_equipment_source(fire_resistance, "Test Armor 2")
    print("Player still has fire resistance: ", player.has_status_effect("fire_resistance"))
    print("Active conditions count: ", player.status_effect_component.active_conditions.size())

    return success1 and success2
