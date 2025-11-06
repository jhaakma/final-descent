extends BaseTest

class_name DirectArmorEnchantTest

func get_test_category() -> String:
    return "DirectArmorEnchant"

func test_exact_rune_usage_scenario() -> bool:
    # Test the EXACT scenario: use rune on fresh armor with no ItemData
    var player := GameState.player
    player.unequip_armor(Equippable.EquipSlot.CUIRASS)

    # Create fresh armor exactly like normal loot
    var armor := Armor.new()
    armor.name = "Fresh Cuirass"
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.condition = 10  # Base condition
    print("DEBUG: Original armor.condition = %d" % armor.condition)

    # Create armor instance WITHOUT ItemData (like normal loot drop)
    var armor_instance := ItemInstance.new(armor, null, 1)
    print("DEBUG: Original armor_instance has ItemData: %s" % str(armor_instance.item_data != null))

    # Add to inventory and equip
    player.add_items(armor_instance)
    var equip_success := player.equip_armor(armor_instance)
    assert_true(equip_success, "Should be able to equip fresh armor")

    # Verify the equipped armor state before enchantment
    var equipped_before: ItemInstance = player.equipped_items[Equippable.EquipSlot.CUIRASS]
    print("DEBUG: Equipped armor has ItemData: %s" % str(equipped_before.item_data != null))
    print("DEBUG: Equipped armor.condition = %d" % (equipped_before.item as Armor).condition)

    # Create the enchanted version exactly like ArmorRune does it
    var selected_armor := equipped_before  # This is what ArmorRune gets
    var original_armor := selected_armor.item as Armor
    print("DEBUG: Selected armor.condition = %d" % original_armor.condition)

    # Duplicate exactly like ArmorRune does
    var enchanted_armor := original_armor.duplicate() as Armor
    print("DEBUG: Duplicated armor.condition = %d" % enchanted_armor.condition)

    var test_enchantment := ConstantEffectEnchantment.new()
    enchanted_armor.enchantment = test_enchantment
    enchanted_armor.name = "%s of %s" % [original_armor.name, "Testing"]

    # Call replace_item_instance exactly like ArmorRune does
    print("DEBUG: About to call replace_item_instance...")
    print("DEBUG: selected_armor has ItemData: %s" % str(selected_armor.item_data != null))
    var replaced_instance := player.replace_item_instance(selected_armor, enchanted_armor)
    assert_true(replaced_instance != null, "Replacement should succeed")

    # Check the final result
    var final_equipped: ItemInstance = player.equipped_items[Equippable.EquipSlot.CUIRASS]
    print("DEBUG: Final armor has ItemData: %s" % str(final_equipped.item_data != null))
    if final_equipped.item_data:
        print("DEBUG: Final condition: %d" % final_equipped.item_data.current_condition)
        print("DEBUG: Final initial condition: %d" % final_equipped.item_data._initial_condition)

    # The critical test - this should reveal the -1 bug
    assert_true(final_equipped.item_data.current_condition != -1,
               "CRITICAL BUG: Condition is -1 after enchantment!")

    return true

func test_actual_armor_rune_usage() -> bool:
    # Test using the actual ArmorRune class like in real gameplay
    var player := GameState.player
    player.unequip_armor(Equippable.EquipSlot.CUIRASS)

    # Create fresh armor exactly like it would be in game
    var armor := Armor.new()
    armor.name = "Game Cuirass"
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.condition = 10

    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)
    player.equip_armor(armor_instance)

    # Create and use actual ArmorRune
    var armor_rune := ArmorRune.new()
    var fire_enchantment := ConstantEffectEnchantment.new()
    armor_rune.armor_enchantment = fire_enchantment
    var rune_item_data := ItemData.new()  # Rune's own ItemData

    # Get the equipped armor instance
    var equipped_armor: ItemInstance = player.equipped_items[Equippable.EquipSlot.CUIRASS]
    print("DEBUG: Before ArmorRune - equipped has ItemData: %s" % str(equipped_armor.item_data != null))

    # Call the actual ArmorRune method like the game does
    armor_rune._on_armor_selected(equipped_armor, fire_enchantment, rune_item_data)

    # Check result
    var final_equipped: ItemInstance = player.equipped_items[Equippable.EquipSlot.CUIRASS]
    if final_equipped and final_equipped.item_data:
        print("DEBUG: After ArmorRune - condition: %d" % final_equipped.item_data.current_condition)
        assert_true(final_equipped.item_data.current_condition != -1,
                   "ArmorRune should not create -1 condition!")
        assert_true(final_equipped.item_data.current_condition > 0,
                   "ArmorRune should create positive condition, got %d" % final_equipped.item_data.current_condition)
    else:
        assert_true(false, "ArmorRune should leave armor equipped with valid ItemData")

    return true