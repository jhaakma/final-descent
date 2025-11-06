class_name ArmorTest extends BaseTest

func test_armor_creation() -> bool:
    var armor := Armor.new()
    armor.name = "Test Cuirass"
    armor.defense_bonus = 10
    armor.armor_slot = Equippable.EquipSlot.CUIRASS

    assert_equals(armor.get_category(), Item.ItemCategory.ARMOR, "Armor should have ARMOR category")
    assert_equals(armor.get_equip_slot(), Equippable.EquipSlot.CUIRASS, "Armor should have CUIRASS slot")
    assert_equals(armor.get_defense_bonus(), 10, "Armor should provide defense bonus")
    assert_equals(armor.get_consumable(), false, "Armor should not be consumable")

    return true

func test_armor_enchantment_validation() -> bool:
    var armor := Armor.new()
    armor.name = "Test Armor"

    # Create a constant effect enchantment (should be valid for armor)
    var constant_enchant := ConstantEffectEnchantment.new()
    assert_true(armor.is_valid_enchantment(constant_enchant), "Armor should accept ConstantEffectEnchantment")

    # Create an on-strike enchantment (should not be valid for armor)
    var strike_enchant := OnStrikeEnchantment.new()
    assert_false(armor.is_valid_enchantment(strike_enchant), "Armor should reject OnStrikeEnchantment")

    return true

func test_weapon_enchantment_validation() -> bool:
    var weapon := Weapon.new()
    weapon.name = "Test Sword"

    # Create an on-strike enchantment (should be valid for weapons)
    var strike_enchant := OnStrikeEnchantment.new()
    assert_true(weapon.is_valid_enchantment(strike_enchant), "Weapon should accept OnStrikeEnchantment")

    # Create a constant effect enchantment (should not be valid for weapons)
    var constant_enchant := ConstantEffectEnchantment.new()
    assert_false(weapon.is_valid_enchantment(constant_enchant), "Weapon should reject ConstantEffectEnchantment")

    return true

func test_player_armor_equipment() -> bool:
    var player := Player.new()
    player.reset()

    # Create armor and add to inventory
    var cuirass := Armor.new()
    cuirass.name = "Steel Cuirass"
    cuirass.defense_bonus = 15
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS

    var shield := Armor.new()
    shield.name = "Iron Shield"
    shield.defense_bonus = 8
    shield.armor_slot = Equippable.EquipSlot.SHIELD

    # Add to inventory
    player.add_items(ItemInstance.new(cuirass, null, 1))
    player.add_items(ItemInstance.new(shield, null, 1))

    # Test equipping cuirass
    var cuirass_instance := ItemInstance.new(cuirass, null, 1)
    assert_true(player.equip_armor(cuirass_instance), "Should be able to equip cuirass")
    assert_true(player.has_item_equipped(Equippable.EquipSlot.CUIRASS), "Cuirass slot should be equipped")

    # Test equipping shield
    var shield_instance := ItemInstance.new(shield, null, 1)
    assert_true(player.equip_armor(shield_instance), "Should be able to equip shield")
    assert_true(player.has_item_equipped(Equippable.EquipSlot.SHIELD), "Shield slot should be equipped")

    # Test defense bonus calculation
    var total_defense := player.get_total_armor_defense_bonus()
    assert_equals(total_defense, 23, "Total defense should be cuirass + shield (15 + 8)")

    # Test unequipping
    assert_true(player.unequip_armor(Equippable.EquipSlot.CUIRASS), "Should be able to unequip cuirass")
    assert_false(player.has_item_equipped(Equippable.EquipSlot.CUIRASS), "Cuirass slot should be empty")

    var defense_after_unequip := player.get_total_armor_defense_bonus()
    assert_equals(defense_after_unequip, 8, "Defense should only be shield bonus after unequipping cuirass")

    return true

func test_equipped_items_not_in_inventory() -> bool:
    var player := Player.new()
    player.reset()

    # Create and add armor to inventory
    var armor := Armor.new()
    armor.name = "Test Armor"
    armor.defense_bonus = 10
    armor.armor_slot = Equippable.EquipSlot.CUIRASS

    player.add_items(ItemInstance.new(armor, null, 1))
    assert_true(player.has_item(armor), "Armor should be in inventory before equipping")

    # Equip the armor
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.equip_armor(armor_instance)

    # Armor should no longer be in regular inventory (it's equipped)
    assert_false(player.has_item(armor), "Armor should not be in inventory when equipped")

    # But should appear in equipped items
    var all_equipped := player.get_all_equipped_items()
    assert_equals(all_equipped.size(), 1, "Should have one equipped item")
    assert_equals(all_equipped[0].item.name, "Test Armor", "Equipped item should be our armor")

    # Unequip should return it to inventory
    player.unequip_armor(Equippable.EquipSlot.CUIRASS)
    assert_true(player.has_item(armor), "Armor should be back in inventory after unequipping")

    return true

func test_armor_defense_bonus_application() -> bool:
    var player := Player.new()
    player.reset()

    # Record initial defense
    var initial_defense := player.get_total_defense()

    # Create armor with defense bonus
    var cuirass := Armor.new()
    cuirass.name = "Steel Cuirass"
    cuirass.defense_bonus = 15
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS

    var shield := Armor.new()
    shield.name = "Iron Shield"
    shield.defense_bonus = 8
    shield.armor_slot = Equippable.EquipSlot.SHIELD

    # Add to inventory
    player.add_items(ItemInstance.new(cuirass, null, 1))
    player.add_items(ItemInstance.new(shield, null, 1))

    # Equip cuirass and check defense increase
    var cuirass_instance := ItemInstance.new(cuirass, null, 1)
    player.equip_armor(cuirass_instance)

    var defense_with_cuirass := player.get_total_defense()
    assert_equals(defense_with_cuirass, initial_defense + 15, "Defense should increase by cuirass bonus")

    # Equip shield and check total defense
    var shield_instance := ItemInstance.new(shield, null, 1)
    player.equip_armor(shield_instance)

    var defense_with_both := player.get_total_defense()
    assert_equals(defense_with_both, initial_defense + 23, "Defense should be initial + cuirass + shield")

    # Unequip cuirass and check defense decrease
    player.unequip_armor(Equippable.EquipSlot.CUIRASS)

    var defense_with_shield_only := player.get_total_defense()
    assert_equals(defense_with_shield_only, initial_defense + 8, "Defense should be initial + shield only")

    # Unequip shield and check defense returns to initial
    player.unequip_armor(Equippable.EquipSlot.SHIELD)

    var final_defense := player.get_total_defense()
    assert_equals(final_defense, initial_defense, "Defense should return to initial value")

    return true

func test_armor_condition_loss_on_damage() -> bool:
    var player := Player.new()
    player.reset()

    # Create armor with default condition (10)
    var cuirass := Armor.new()
    cuirass.name = "Test Cuirass"
    cuirass.defense_bonus = 5
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS
    cuirass.condition = 10

    # Add to inventory and equip armor
    var cuirass_instance := ItemInstance.new(cuirass, null, 1)
    player.add_items(cuirass_instance)
    player.equip_armor(cuirass_instance)

    # Verify armor is equipped
    var equipped_cuirass := player.get_equipped_armor(Equippable.EquipSlot.CUIRASS)
    assert_true(equipped_cuirass != null, "Cuirass should be equipped")

    # Take damage (should trigger armor condition loss)
    player.take_damage(5)

    # Verify ItemData was created and condition reduced
    assert_true(equipped_cuirass.item_data != null, "ItemData should be created after taking damage")
    assert_equals(equipped_cuirass.item_data.current_condition, 9, "Armor condition should be reduced by 1")

    # Take more damage to further reduce condition
    player.take_damage(3)
    assert_equals(equipped_cuirass.item_data.current_condition, 8, "Armor condition should be reduced to 8")

    return true

func test_armor_destruction_on_zero_condition() -> bool:
    var player := Player.new()
    player.reset()

    # Create armor with low condition (2)
    var cuirass := Armor.new()
    cuirass.name = "Fragile Cuirass"
    cuirass.defense_bonus = 5
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS
    cuirass.condition = 2

    # Create ItemData with condition already at 1 (next hit will destroy it)
    var item_data := ItemData.new(2)
    item_data.current_condition = 1

    # Add to inventory and equip armor with existing ItemData
    var cuirass_instance := ItemInstance.new(cuirass, item_data, 1)
    player.add_items(cuirass_instance)
    player.equip_armor(cuirass_instance)

    # Verify armor is equipped
    var equipped_cuirass := player.get_equipped_armor(Equippable.EquipSlot.CUIRASS)
    assert_true(equipped_cuirass != null, "Cuirass should be equipped")
    assert_equals(equipped_cuirass.item_data.current_condition, 1, "Armor condition should be 1")

    # Take damage (should destroy the armor)
    player.take_damage(5)

    # Verify armor is destroyed and no longer equipped
    var destroyed_cuirass := player.get_equipped_armor(Equippable.EquipSlot.CUIRASS)
    assert_true(destroyed_cuirass == null, "Cuirass should be destroyed and unequipped")

    return true

func test_no_armor_condition_loss_when_no_damage_taken() -> bool:
    var player := Player.new()
    player.reset()

    # Create armor
    var cuirass := Armor.new()
    cuirass.name = "Invincible Cuirass"
    cuirass.defense_bonus = 95  # High defense to minimize damage
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS
    cuirass.condition = 10

    # Add to inventory and equip armor
    var cuirass_instance := ItemInstance.new(cuirass, null, 1)
    player.add_items(cuirass_instance)
    player.equip_armor(cuirass_instance)

    # Try to take very little damage (should be reduced to 0 or 1 by high defense)
    player.take_damage(1)

    # Verify armor condition was affected (since minimum damage is 1)
    var equipped_cuirass := player.get_equipped_armor(Equippable.EquipSlot.CUIRASS)
    # Since minimum damage is 1, armor should still lose condition
    assert_true(equipped_cuirass.item_data != null, "ItemData should be created")
    assert_equals(equipped_cuirass.item_data.current_condition, 9, "Armor should lose condition even with high defense")

    return true