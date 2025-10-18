class_name HelmetEquipTest extends BaseTest

func test_leather_helmet_equipment() -> bool:
    # Reset player state
    var player := GameState.player
    player.reset()

    # Load the actual leather helmet resource
    var helmet_resource := load("res://data/items/armor/LeatherHelmet.tres") as Armor
    assert_not_null(helmet_resource, "Leather helmet resource should load")

    # Verify the helmet has the correct slot
    assert_equals(helmet_resource.get_equip_slot(), Equippable.EquipSlot.HELMET, "Helmet should have HELMET slot")
    assert_equals(helmet_resource.armor_slot, Equippable.EquipSlot.HELMET, "Helmet armor_slot should match HELMET enum")

    # Add helmet to inventory
    var helmet_instance := ItemInstance.new(helmet_resource, null, 1)
    player.inventory.add_item(helmet_instance)

    # Verify helmet is in inventory
    assert_true(player.has_item(helmet_resource), "Helmet should be in inventory")

    # Equip the helmet
    var equip_result := player.equip_item(helmet_instance)
    assert_true(equip_result, "Helmet equipping should succeed")

    # Verify helmet is equipped
    assert_true(player.has_item_equipped(Equippable.EquipSlot.HELMET), "Helmet should be equipped")

    var equipped_helmet := player.get_equipped_item(Equippable.EquipSlot.HELMET)
    assert_not_null(equipped_helmet, "Equipped helmet should not be null")
    assert_equals(equipped_helmet.item.name, "Leather Helmet", "Equipped item should be the leather helmet")

    # Verify helmet is no longer in regular inventory
    assert_false(player.has_item(helmet_resource), "Helmet should no longer be in inventory after equipping")

    return true

func test_all_new_armor_slots_work() -> bool:
    # Reset player state
    var player := GameState.player
    player.reset()

    # Test helmet
    var helmet := load("res://data/items/armor/LeatherHelmet.tres") as Armor
    var helmet_instance := ItemInstance.new(helmet, null, 1)
    player.inventory.add_item(helmet_instance)
    assert_true(player.equip_item(helmet_instance), "Helmet should equip successfully")
    assert_true(player.has_item_equipped(Equippable.EquipSlot.HELMET), "Helmet should be equipped")

    # Test gloves
    var gloves := load("res://data/items/armor/LeatherGloves.tres") as Armor
    var gloves_instance := ItemInstance.new(gloves, null, 1)
    player.inventory.add_item(gloves_instance)
    assert_true(player.equip_item(gloves_instance), "Gloves should equip successfully")
    assert_true(player.has_item_equipped(Equippable.EquipSlot.GLOVES), "Gloves should be equipped")

    # Test boots
    var boots := load("res://data/items/armor/LeatherBoots.tres") as Armor
    var boots_instance := ItemInstance.new(boots, null, 1)
    player.inventory.add_item(boots_instance)
    assert_true(player.equip_item(boots_instance), "Boots should equip successfully")
    assert_true(player.has_item_equipped(Equippable.EquipSlot.BOOTS), "Boots should be equipped")

    # Test cuirass (existing functionality)
    var cuirass := load("res://data/items/armor/LeatherCuirass.tres") as Armor
    var cuirass_instance := ItemInstance.new(cuirass, null, 1)
    player.inventory.add_item(cuirass_instance)
    assert_true(player.equip_item(cuirass_instance), "Cuirass should equip successfully")
    assert_true(player.has_item_equipped(Equippable.EquipSlot.CUIRASS), "Cuirass should be equipped")

    # Verify all items are equipped
    var equipped_items := player.get_all_equipped_items()
    assert_equals(equipped_items.size(), 4, "Should have 4 equipped armor pieces")

    return true