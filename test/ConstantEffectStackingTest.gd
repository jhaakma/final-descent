class_name ConstantEffectStackingTest extends BaseTest

func get_test_name() -> String:
    return "ConstantEffectStackingTest"

# Test that constant effects from equipment can stack while showing single UI effect
func test_constant_effect_equipment_stacking() -> bool:
    var player := GameState.player

    # Create a fire resistance effect
    var fire_resistance := ElementalResistanceEffect.new()
    fire_resistance.elemental_type = DamageType.Type.FIRE
    fire_resistance.resistance_percentage = 25

    # Create two different armor pieces with the same fire resistance enchantment
    var armor1 := Armor.new()
    armor1.name = "Fire Helm"
    armor1.armor_slot = Equippable.EquipSlot.HELMET

    var armor2 := Armor.new()
    armor2.name = "Fire Cuirass"
    armor2.armor_slot = Equippable.EquipSlot.CUIRASS

    # Create constant effect enchantments for both armor pieces
    var enchant1 := ConstantEffectEnchantment.new()
    enchant1.constant_effect = fire_resistance
    armor1.enchantment = enchant1

    var enchant2 := ConstantEffectEnchantment.new()
    enchant2.constant_effect = fire_resistance.duplicate()  # Same effect type
    armor2.enchantment = enchant2

    # Clear any existing effects and equipment
    player.clear_all_status_effects()
    player.unequip_all()

    # Test: Apply first armor - should show fire resistance
    var armor1_instance := ItemInstance.new(armor1, null, 1)
    player.add_items(armor1_instance)
    player.equip_armor(armor1_instance)

    assert_true(player.has_status_effect("fire_resistance"), "Should have fire resistance from first armor")
    var effect_count_after_first := player.status_effect_component.get_effect_count()

    # Test: Apply second armor - should NOT show duplicate fire resistance in UI
    var armor2_instance := ItemInstance.new(armor2, null, 1)
    player.add_items(armor2_instance)
    player.equip_armor(armor2_instance)

    assert_true(player.has_status_effect("fire_resistance"), "Should still have fire resistance")
    var effect_count_after_second := player.status_effect_component.get_effect_count()

    # Key test: Effect count should be the same (no duplicate UI entry)
    assert_equals(effect_count_after_first, effect_count_after_second, "Should not show duplicate fire resistance in UI")

    # Verify the condition has multiple sources tracked internally
    var condition := player.status_effect_component.get_effect("fire_resistance")
    assert_true(condition != null, "Should have fire resistance condition")
    assert_true(condition.has_equipment_sources(), "Should have equipment sources")
    assert_equals(condition.equipment_sources.size(), 2, "Should track two equipment sources")

    # Test: Remove first armor - fire resistance should persist (from second armor)
    player.unequip_armor(Equippable.EquipSlot.HELMET)

    assert_true(player.has_status_effect("fire_resistance"), "Should keep fire resistance from second armor")

    # Verify only one source remains
    condition = player.status_effect_component.get_effect("fire_resistance")
    assert_true(condition != null, "Should still have fire resistance condition")
    assert_equals(condition.equipment_sources.size(), 1, "Should have one equipment source remaining")

    # Test: Remove second armor - fire resistance should be removed entirely
    player.unequip_armor(Equippable.EquipSlot.CUIRASS)

    assert_false(player.has_status_effect("fire_resistance"), "Should remove fire resistance when no sources remain")

    return true

# Test that consumable effects still show "already affected" message
func test_consumable_effects_dont_stack() -> bool:
    var player := GameState.player

    # Create a simple constant effect (like from a potion)
    var strength_boost := StrengthBoostEffect.new()
    strength_boost.strength_bonus = 2

    # Clear any existing effects
    player.clear_all_status_effects()

    # Apply first effect as consumable (default behavior)
    var condition1 := StatusCondition.from_status_effect(strength_boost)
    player.apply_status_condition(condition1)

    assert_true(player.has_status_effect("strength_boost"), "Should have strength boost from first application")
    var effect_count_after_first := player.status_effect_component.get_effect_count()

    # Try to apply same effect again - should be rejected
    var condition2 := StatusCondition.from_status_effect(strength_boost.duplicate())
    var success := player.apply_status_condition(condition2)

    assert_false(success, "Should reject duplicate consumable effect")
    var effect_count_after_second := player.status_effect_component.get_effect_count()
    assert_equals(effect_count_after_first, effect_count_after_second, "Effect count should be unchanged")

    return true