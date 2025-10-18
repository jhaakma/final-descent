extends BaseTest

func get_test_name() -> String:
    return "EquipmentUnequipTest"

# Test actual equipment equip/unequip behavior
func test_armor_enchantment_removal() -> bool:
    var player := GameState.player
    
    # Clear everything first
    player.clear_all_status_effects()
    player.unequip_armor(Equippable.EquipSlot.HELMET)
    player.unequip_armor(Equippable.EquipSlot.CUIRASS)
    
    # Create fire resistance effect
    var fire_resistance := ElementalResistanceEffect.new()
    fire_resistance.elemental_type = DamageType.Type.FIRE
    
    # Create first armor with fire resistance enchantment
    var armor1 := Armor.new()
    armor1.name = "Fire Helm"
    armor1.armor_slot = Equippable.EquipSlot.HELMET
    
    var enchant1 := ConstantEffectEnchantment.new()
    enchant1.constant_effect = fire_resistance
    armor1.enchantment = enchant1
    
    # Create second armor with fire resistance enchantment
    var armor2 := Armor.new()
    armor2.name = "Fire Cuirass"
    armor2.armor_slot = Equippable.EquipSlot.CUIRASS
    
    var enchant2 := ConstantEffectEnchantment.new()
    enchant2.constant_effect = fire_resistance.duplicate()
    armor2.enchantment = enchant2
    
    print("=== Testing Actual Equipment Behavior ===")
    
    # Equip first armor
    var armor1_instance := ItemInstance.new(armor1, null, 1)
    player.add_items(armor1_instance)
    var success1 := player.equip_armor(armor1_instance)
    print("Equipped first armor: ", success1)
    print("Has fire resistance after first: ", player.has_status_effect("fire_resistance"))
    
    # Check equipment stack count
    var condition := player.status_effect_component.get_effect("fire_resistance")
    if condition:
        print("Stack count after first: ", condition.equipment_stack_count)
    
    # Equip second armor
    var armor2_instance := ItemInstance.new(armor2, null, 1)
    player.add_items(armor2_instance)
    var success2 := player.equip_armor(armor2_instance)
    print("Equipped second armor: ", success2)
    print("Has fire resistance after second: ", player.has_status_effect("fire_resistance"))
    
    # Check equipment stack count
    condition = player.status_effect_component.get_effect("fire_resistance")
    if condition:
        print("Stack count after second: ", condition.equipment_stack_count)
    
    # Unequip first armor
    print("\n--- Unequipping First Armor ---")
    player.unequip_armor(Equippable.EquipSlot.HELMET)
    print("Has fire resistance after unequipping first: ", player.has_status_effect("fire_resistance"))
    
    condition = player.status_effect_component.get_effect("fire_resistance")
    if condition:
        print("Stack count after unequipping first: ", condition.equipment_stack_count)
    
    # Unequip second armor
    print("\n--- Unequipping Second Armor ---")
    player.unequip_armor(Equippable.EquipSlot.CUIRASS)
    print("Has fire resistance after unequipping both: ", player.has_status_effect("fire_resistance"))
    print("Active conditions count: ", player.status_effect_component.active_conditions.size())
    
    return true