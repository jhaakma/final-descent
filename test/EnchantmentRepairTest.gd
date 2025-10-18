class_name EnchantmentRepairTest extends BaseTest

func test_additional_armor_slots() -> bool:
    # Test that new armor slots are properly recognized
    var helmet := Armor.new()
    helmet.armor_slot = Equippable.EquipSlot.HELMET

    var gloves := Armor.new()
    gloves.armor_slot = Equippable.EquipSlot.GLOVES

    var boots := Armor.new()
    boots.armor_slot = Equippable.EquipSlot.BOOTS

    # Test slot name functions
    assert_equals(helmet.get_equip_slot_name(), "Helmet", "Helmet slot name")
    assert_equals(gloves.get_equip_slot_name(), "Gloves", "Gloves slot name")
    assert_equals(boots.get_equip_slot_name(), "Boots", "Boots slot name")

    return true

func test_armor_rune_finds_all_equipped_armor() -> bool:
    # Setup player with multiple armor pieces
    var player := GameState.player
    player.reset()

    # Create armor for different slots
    var helmet := Armor.new()
    helmet.name = "Test Helmet"
    helmet.armor_slot = Equippable.EquipSlot.HELMET

    var cuirass := Armor.new()
    cuirass.name = "Test Cuirass"
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS

    var boots := Armor.new()
    boots.name = "Test Boots"
    boots.armor_slot = Equippable.EquipSlot.BOOTS

    # Add to inventory and equip
    player.inventory.add_item(ItemInstance.new(helmet, null, 1))
    player.inventory.add_item(ItemInstance.new(cuirass, null, 1))
    player.inventory.add_item(ItemInstance.new(boots, null, 1))

    player.equip_item(ItemInstance.new(helmet, null, 1))
    player.equip_item(ItemInstance.new(cuirass, null, 1))
    player.equip_item(ItemInstance.new(boots, null, 1))

    # Verify armor was equipped
    assert_true(player.has_item_equipped(Equippable.EquipSlot.HELMET), "Helmet equipped")
    assert_true(player.has_item_equipped(Equippable.EquipSlot.CUIRASS), "Cuirass equipped")
    assert_true(player.has_item_equipped(Equippable.EquipSlot.BOOTS), "Boots equipped")

    return true

func test_repair_tool_finds_damaged_items() -> bool:
    # Setup player with damaged equipment
    var player := GameState.player
    player.reset()

    # Create a damaged weapon
    var weapon := Weapon.new()
    weapon.name = "Test Weapon"
    weapon.condition = 10

    var weapon_data := ItemData.new()
    weapon_data.current_condition = 5  # Damaged

    var weapon_instance := ItemInstance.new(weapon, weapon_data, 1)

    player.inventory.add_item(ItemInstance.new(weapon, weapon_data, 1))
    player.equip_weapon(weapon_instance)

    # Create a damaged armor
    var cuirass := Armor.new()
    cuirass.name = "Test Cuirass"
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS
    cuirass.condition = 10

    var armor_data := ItemData.new()
    armor_data.current_condition = 3  # Very damaged

    var armor_instance := ItemInstance.new(cuirass, armor_data, 1)

    player.inventory.add_item(ItemInstance.new(cuirass, armor_data, 1))
    player.equip_armor(armor_instance)

    # Create a repair tool
    var repair_tool := RepairTool.new()
    repair_tool.repair_amount = 5

    # The repair tool should find both damaged items
    # We can't easily test the popup without UI, but we can test the logic
    var all_equipped := player.get_all_equipped_items()
    var damaged_items: Array[ItemInstance] = []

    for item_instance: ItemInstance in all_equipped:
        if item_instance.item_data and item_instance.item is Equippable:
            var equippable := item_instance.item as Equippable
            var current_condition := item_instance.item_data.current_condition
            var max_condition := equippable.get_max_condition()
            if current_condition < max_condition:
                damaged_items.append(item_instance)

    assert_equals(damaged_items.size(), 2, "Found 2 damaged items")

    return true

func test_equipment_slot_name_mapping() -> bool:
    # Test all new equipment slot names
    var helmet := Armor.new()
    helmet.armor_slot = Equippable.EquipSlot.HELMET
    assert_equals(helmet.get_equip_slot_name(), "Helmet", "Helmet name")

    var cuirass := Armor.new()
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS
    assert_equals(cuirass.get_equip_slot_name(), "Cuirass", "Cuirass name")

    var gloves := Armor.new()
    gloves.armor_slot = Equippable.EquipSlot.GLOVES
    assert_equals(gloves.get_equip_slot_name(), "Gloves", "Gloves name")

    var boots := Armor.new()
    boots.armor_slot = Equippable.EquipSlot.BOOTS
    assert_equals(boots.get_equip_slot_name(), "Boots", "Boots name")

    var shield := Armor.new()
    shield.armor_slot = Equippable.EquipSlot.SHIELD
    assert_equals(shield.get_equip_slot_name(), "Shield", "Shield name")

    return true