class_name ArmorResistanceIntegrationTest extends BaseTest

func test_armor_resistance_applied_to_player() -> bool:
    # Create a player
    var player := Player.new()
    player.reset()

    # Create armor with fire resistance
    var armor := Armor.new()
    armor.name = "Fire Resistant Armor"
    armor.defense_bonus = 5
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.set_resistance(DamageType.Type.FIRE, true)

    # Create item instance and add to inventory first
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)

    # Equip the armor
    var equipped := player.equip_armor(armor_instance)

    if not equipped:
        print("Failed to equip armor")
        return false

    # Check that player now has fire resistance
    if not player.is_resistant_to(DamageType.Type.FIRE):
        print("Player should have fire resistance after equipping armor")
        return false

    # Check that player doesn't have other resistances
    if player.is_resistant_to(DamageType.Type.ICE):
        print("Player should not have ice resistance")
        return false

    # Unequip armor and check resistance is removed
    var unequipped := player.unequip_armor(Equippable.EquipSlot.CUIRASS)
    if not unequipped:
        print("Failed to unequip armor")
        return false

    # Check that resistance is gone
    if player.is_resistant_to(DamageType.Type.FIRE):
        print("Player should not have fire resistance after unequipping armor")
        return false

    return true

func test_armor_resistance_reduces_damage() -> bool:
    # Create player
    var player := Player.new()
    player.reset()

    # Create armor with fire resistance
    var armor := Armor.new()
    armor.name = "Fire Resistant Armor"
    armor.defense_bonus = 0  # No defense bonus to isolate resistance effect
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.set_resistance(DamageType.Type.FIRE, true)

    # Test fire damage without armor resistance first
    var base_damage := 10
    var damage_without_resistance: int = player.calculate_incoming_damage(base_damage, DamageType.Type.FIRE)

    # Add to inventory and equip the armor for resistance test
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)
    player.equip_armor(armor_instance)
    var damage_with_resistance: int = player.calculate_incoming_damage(base_damage, DamageType.Type.FIRE)

    # With resistance, damage should be halved (50% reduction)
    var expected_damage := int(base_damage * 0.5)

    if damage_with_resistance != expected_damage:
        print("Expected damage with resistance: %d, got: %d" % [expected_damage, damage_with_resistance])
        return false

    # Damage with resistance should be less than without resistance
    if damage_with_resistance >= damage_without_resistance:
        print("Damage with resistance (%d) should be less than without resistance (%d)" % [damage_with_resistance, damage_without_resistance])
        return false

    return true

func test_multiple_armor_resistances() -> bool:
    # Create player
    var player := Player.new()
    player.reset()

    # Create armor with multiple resistances
    var armor := Armor.new()
    armor.name = "Multi-Resistant Armor"
    armor.defense_bonus = 0
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.set_resistance(DamageType.Type.FIRE, true)
    armor.set_resistance(DamageType.Type.ICE, true)
    armor.set_resistance(DamageType.Type.POISON, true)

    # Add to inventory and equip the armor
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)
    player.equip_armor(armor_instance)

    # Check all resistances are applied
    if not player.is_resistant_to(DamageType.Type.FIRE):
        print("Player should have fire resistance")
        return false

    if not player.is_resistant_to(DamageType.Type.ICE):
        print("Player should have ice resistance")
        return false

    if not player.is_resistant_to(DamageType.Type.POISON):
        print("Player should have poison resistance")
        return false

    # Check non-resistant types
    if player.is_resistant_to(DamageType.Type.SHOCK):
        print("Player should not have shock resistance")
        return false

    # Test damage reduction for each type
    var base_damage := 10
    var expected_damage := int(base_damage * 0.5)

    var fire_damage: int = player.calculate_incoming_damage(base_damage, DamageType.Type.FIRE)
    var ice_damage: int = player.calculate_incoming_damage(base_damage, DamageType.Type.ICE)
    var poison_damage: int = player.calculate_incoming_damage(base_damage, DamageType.Type.POISON)
    var shock_damage: int = player.calculate_incoming_damage(base_damage, DamageType.Type.SHOCK)

    if fire_damage != expected_damage:
        print("Fire damage should be %d, got %d" % [expected_damage, fire_damage])
        return false

    if ice_damage != expected_damage:
        print("Ice damage should be %d, got %d" % [expected_damage, ice_damage])
        return false

    if poison_damage != expected_damage:
        print("Poison damage should be %d, got %d" % [expected_damage, poison_damage])
        return false

    # Shock damage should not be reduced
    if shock_damage == expected_damage:
        print("Shock damage should not be reduced, expected %d, got %d" % [base_damage, shock_damage])
        return false

    return true

func test_generated_armor_resistance_integration() -> bool:
    # Create armor material with resistances
    var material := ArmorMaterial.new()
    material.name = "Dragon Scale"
    material.defense_modifier = 1.0
    material.condition_modifier = 1.0
    material.purchase_value_modifier = 1.0
    material.set_resistance(DamageType.Type.FIRE, true)
    material.set_resistance(DamageType.Type.DARK, true)

    # Create armor template
    var template := ArmorTemplate.new()
    template.base_name = "Plate"
    template.base_defense = 8
    template.armor_slot = Equippable.EquipSlot.CUIRASS
    template.base_condition = 30
    template.base_purchase_value = 100

    # Generate armor
    var generator := ArmorGenerator.new()
    generator.armor_templates = [template]
    generator.materials = [material]

    var generated_armor: Item = generator.generate_item()
    if not generated_armor is Armor:
        print("Generated item should be armor")
        return false

    var armor: Armor = generated_armor as Armor

    # Verify resistances were applied to generated armor
    if not armor.get_resistance(DamageType.Type.FIRE):
        print("Generated armor should have fire resistance")
        return false

    if not armor.get_resistance(DamageType.Type.DARK):
        print("Generated armor should have dark resistance")
        return false

    # Test that generated armor provides resistance when equipped
    var player := Player.new()
    player.reset()

    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)
    player.equip_armor(armor_instance)

    # Check player has resistances from generated armor
    if not player.is_resistant_to(DamageType.Type.FIRE):
        print("Player should have fire resistance from generated armor")
        return false

    if not player.is_resistant_to(DamageType.Type.DARK):
        print("Player should have dark resistance from generated armor")
        return false

    return true
