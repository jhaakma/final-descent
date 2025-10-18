class_name EquippedItemSellTest extends BaseTest

func test_selling_equipped_armor_removes_from_player() -> bool:
    var player := Player.new()
    player.reset()

    # Load a real armor item from the data
    var leather_cuirass: Armor = load("res://data/items/armor/LeatherCuirass.tres")
    assert_not_null(leather_cuirass, "Should load leather cuirass from data")

    # Create item instance and add to inventory
    var cuirass_instance := ItemInstance.new(leather_cuirass, null, 1)
    player.add_items(cuirass_instance)

    # Verify it's in inventory
    assert_true(player.has_item(leather_cuirass), "Player should have cuirass in inventory")

    # Equip the armor
    var equipped_successfully := player.equip_item(cuirass_instance)
    assert_true(equipped_successfully, "Should successfully equip cuirass")

    # Verify it's equipped
    var equipped_cuirass := player.get_equipped_armor(Equippable.EquipSlot.CUIRASS)
    assert_not_null(equipped_cuirass, "Should have equipped cuirass")
    assert_true(equipped_cuirass.is_equipped, "Cuirass should be marked as equipped")

    # Verify it appears in get_item_tiles (this is what the shop sees)
    var all_tiles := player.get_item_tiles()
    var has_cuirass_tile := false
    for tile in all_tiles:
        if tile.item == leather_cuirass and tile.is_equipped:
            has_cuirass_tile = true
            break
    assert_true(has_cuirass_tile, "Equipped cuirass should appear in get_item_tiles")

    # Now attempt to sell/remove the equipped armor - this simulates what happens in the shop
    var remove_successful := player.remove_item(equipped_cuirass)
    assert_true(remove_successful, "Should successfully remove equipped armor")
    
    # After removal, verify it's no longer equipped
    var equipped_after_removal := player.get_equipped_armor(Equippable.EquipSlot.CUIRASS)
    assert_null(equipped_after_removal, "Should have no equipped cuirass after removal")    # Verify it doesn't appear in get_item_tiles anymore
    var tiles_after_removal := player.get_item_tiles()
    var still_has_cuirass_tile := false
    for tile in tiles_after_removal:
        if tile.item == leather_cuirass:
            still_has_cuirass_tile = true
            break
    assert_false(still_has_cuirass_tile, "Cuirass should not appear in get_item_tiles after removal")

    # Also verify it's not in the regular inventory
    assert_false(player.has_item(leather_cuirass), "Player should not have cuirass in inventory after removal")
    
    return true

func test_selling_equipped_weapon_removes_from_player() -> bool:
    var player := Player.new()
    player.reset()

    # Load a real weapon item from the data
    var short_sword: Weapon = load("res://data/items/weapons/ShortSword.tres")
    assert_not_null(short_sword, "Should load short sword from data")

    # Create item instance and add to inventory
    var sword_instance := ItemInstance.new(short_sword, null, 1)
    player.add_items(sword_instance)

    # Equip the weapon
    var equipped_successfully := player.equip_weapon(sword_instance)
    assert_true(equipped_successfully, "Should successfully equip sword")

    # Verify it's equipped
    assert_not_null(player.equipped_weapon, "Should have equipped weapon")
    assert_true(player.equipped_weapon.is_equipped, "Weapon should be marked as equipped")

    # Now attempt to sell/remove the equipped weapon
    var remove_successful := player.remove_item(player.equipped_weapon)
    assert_true(remove_successful, "Should successfully remove equipped weapon")

    # After removal, verify it's no longer equipped
    assert_null(player.equipped_weapon, "Should have no equipped weapon after removal")

    return true

func test_selling_equipped_helmet_removes_from_player() -> bool:
    var player := Player.new()
    player.reset()

    # Load a real helmet item from the data
    var leather_helmet: Armor = load("res://data/items/armor/LeatherHelmet.tres")
    assert_not_null(leather_helmet, "Should load leather helmet from data")

    # Create item instance and add to inventory
    var helmet_instance := ItemInstance.new(leather_helmet, null, 1)
    player.add_items(helmet_instance)

    # Equip the helmet
    var equipped_successfully := player.equip_item(helmet_instance)
    assert_true(equipped_successfully, "Should successfully equip helmet")

    # Verify it's equipped
    var equipped_helmet := player.get_equipped_armor(Equippable.EquipSlot.HELMET)
    assert_not_null(equipped_helmet, "Should have equipped helmet")
    assert_true(equipped_helmet.is_equipped, "Helmet should be marked as equipped")

    # Now attempt to sell/remove the equipped helmet
    var remove_successful := player.remove_item(equipped_helmet)
    assert_true(remove_successful, "Should successfully remove equipped helmet")

    # After removal, verify it's no longer equipped
    var helmet_after_removal := player.get_equipped_armor(Equippable.EquipSlot.HELMET)
    assert_null(helmet_after_removal, "Should have no equipped helmet after removal")

    return true