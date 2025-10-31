class_name ArmorResistanceUITest extends BaseTest

func test_armor_resistance_shows_in_status_effects() -> bool:
    # Create armor with multiple resistances
    var armor := Armor.new()
    armor.name = "Multi-Resistant Plate"
    armor.defense_bonus = 10
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.set_resistance(DamageType.Type.FIRE, true)
    armor.set_resistance(DamageType.Type.ICE, true)

    # Create player and equip armor
    var player := Player.new()
    player.reset()

    # Check no status effects initially
    assert(player.status_effect_component.active_conditions.size() == 0)

    # Equip armor
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)
    var equipped := player.equip_armor(armor_instance)
    assert(equipped)

    # Check that status effects are created for UI display
    var active_conditions := player.status_effect_component.active_conditions
    assert(active_conditions.size() == 2)  # Fire and Ice resistance

    # Verify the status effects have the correct IDs for proper stacking
    var has_fire_resistance := false
    var has_ice_resistance := false

    for condition_id: String in active_conditions.keys():
        if condition_id == "Fire Resistance":
            has_fire_resistance = true
        elif condition_id == "Ice Resistance":
            has_ice_resistance = true

    assert(has_fire_resistance)
    assert(has_ice_resistance)

    # Verify the effects actually provide resistance
    assert(player.is_resistant_to(DamageType.Type.FIRE))
    assert(player.is_resistant_to(DamageType.Type.ICE))
    assert(not player.is_resistant_to(DamageType.Type.BLUNT))

    # Unequip and verify effects are removed
    var unequipped := player.unequip_armor(Equippable.EquipSlot.CUIRASS)
    assert(unequipped)

    # Check status effects are removed
    active_conditions = player.status_effect_component.active_conditions
    assert(active_conditions.size() == 0)

    # Verify resistances are gone
    assert(not player.is_resistant_to(DamageType.Type.FIRE))
    assert(not player.is_resistant_to(DamageType.Type.ICE))

    return true

func test_armor_resistance_stacks_with_magical_resistance() -> bool:
    # Create armor with fire resistance
    var armor := Armor.new()
    armor.name = "Fire Resistant Armor"
    armor.defense_bonus = 5
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.set_resistance(DamageType.Type.FIRE, true)

    # Create player
    var player := Player.new()
    player.reset()

    # Apply a magical fire resistance effect first
    var magical_resistance := ElementalResistanceEffect.new()
    magical_resistance.elemental_type = DamageType.Type.FIRE
    var magical_condition := StatusCondition.from_status_effect(magical_resistance)
    player.status_effect_component.apply_status_condition(magical_condition, player)

    # Verify magical resistance works
    assert(player.is_resistant_to(DamageType.Type.FIRE))
    assert(player.status_effect_component.active_conditions.size() == 1)

    # Equip armor with same resistance type
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)
    var equipped := player.equip_armor(armor_instance)
    assert(equipped)

    # Verify still resistant (should stack properly)
    assert(player.is_resistant_to(DamageType.Type.FIRE))

    # Check that there's still only one condition (stacking/deduplication working)
    var active_conditions := player.status_effect_component.active_conditions
    assert(active_conditions.size() == 1)  # Should be deduplicated by effect_id
    assert(active_conditions.has("Fire Resistance"))

    # Unequip armor - should still have magical resistance
    var unequipped := player.unequip_armor(Equippable.EquipSlot.CUIRASS)
    assert(unequipped)

    # Should still be resistant from magical effect
    assert(player.is_resistant_to(DamageType.Type.FIRE))
    assert(player.status_effect_component.active_conditions.size() == 1)

    return true

func test_armor_resistance_removed_on_unequip() -> bool:
    # Test that armor resistances are properly removed from both combat system and UI when unequipping

    # Create armor with multiple resistances
    var armor := Armor.new()
    armor.name = "Elemental Protection Armor"
    armor.defense_bonus = 0  # No defense bonus to isolate resistance effect
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.set_resistance(DamageType.Type.FIRE, true)
    armor.set_resistance(DamageType.Type.ICE, true)
    armor.set_resistance(DamageType.Type.POISON, true)

    # Create player
    var player := Player.new()
    player.reset()

    # Verify no initial resistances
    assert(not player.is_resistant_to(DamageType.Type.FIRE))
    assert(not player.is_resistant_to(DamageType.Type.ICE))
    assert(not player.is_resistant_to(DamageType.Type.POISON))
    assert(player.status_effect_component.active_conditions.size() == 0)

    # Equip armor
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)
    var equipped := player.equip_armor(armor_instance)
    assert(equipped)

    # Verify resistances are applied
    assert(player.is_resistant_to(DamageType.Type.FIRE))
    assert(player.is_resistant_to(DamageType.Type.ICE))
    assert(player.is_resistant_to(DamageType.Type.POISON))
    assert(player.status_effect_component.active_conditions.size() == 3)

    # Verify UI shows the resistance effects
    var active_conditions := player.status_effect_component.active_conditions
    assert(active_conditions.has("Fire Resistance"), "UI should show Fire Resistance effect")
    assert(active_conditions.has("Ice Resistance"), "UI should show Ice Resistance effect")
    assert(active_conditions.has("Poison Resistance"), "UI should show Poison Resistance effect")

    # Test damage reduction works
    var base_damage := 20
    var damage_with_resistance: int = player.calculate_incoming_damage(base_damage, DamageType.Type.FIRE)
    assert(damage_with_resistance == 10)  # 50% reduction

    # Unequip armor
    var unequipped := player.unequip_armor(Equippable.EquipSlot.CUIRASS)
    assert(unequipped)

    # Verify all resistances are removed
    assert(not player.is_resistant_to(DamageType.Type.FIRE))
    assert(not player.is_resistant_to(DamageType.Type.ICE))
    assert(not player.is_resistant_to(DamageType.Type.POISON))
    assert(player.status_effect_component.active_conditions.size() == 0)

    # Verify UI no longer shows any resistance effects
    var remaining_conditions := player.status_effect_component.active_conditions
    assert(not remaining_conditions.has("Fire Resistance"))
    assert(not remaining_conditions.has("Ice Resistance"))
    assert(not remaining_conditions.has("Poison Resistance"))

    # Verify no resistance-related status effects remain in UI
    for condition_name: String in remaining_conditions.keys():
        assert(not condition_name.contains("Resistance"), "Found remaining resistance effect: " + condition_name)

    # Test damage reduction no longer works
    var damage_without_resistance: int = player.calculate_incoming_damage(base_damage, DamageType.Type.FIRE)
    assert(damage_without_resistance == 20)  # No reduction

    return true