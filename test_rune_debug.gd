## Test script to debug rune consumption
extends Node

func _ready() -> void:
    # Give the scene time to load
    await get_tree().process_frame
    test_rune_usage()

func test_rune_usage() -> void:
    print("=== TESTING RUNE USAGE ===")

    # Create a test rune
    var armor_rune := ArmorRune.new()
    armor_rune.name = "Test Fire Rune"
    var test_enchantment := ConstantEffectEnchantment.new()
    test_enchantment.name = "Fire Enhancement"
    armor_rune.armor_enchantment = test_enchantment

    # Create test armor and add to player inventory
    var armor := Armor.new()
    armor.name = "Test Cuirass"
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    var armor_data := ItemData.new()
    armor_data.current_condition = 100
    var armor_instance := ItemInstance.new(armor, armor_data, 1)

    # Add armor to player
    print("Adding armor to player...")
    GameState.player.add_items(armor_instance)
    GameState.player.equip_armor(armor_instance)

    # Add rune to player inventory
    var rune_data := ItemData.new()
    var rune_instance := ItemInstance.new(armor_rune, rune_data, 1)
    print("Adding rune to player...")
    GameState.player.add_items(rune_instance)

    # Test using the rune
    print("Testing rune usage...")
    var consumption_handler := armor_rune.use(rune_data, rune_instance)
    print("Consumption handler returned: ", consumption_handler)

    if consumption_handler:
        print("Consumption handler created successfully")
        # Simulate clicking on the armor to enchant it
        print("Simulating armor selection...")
        armor_rune._on_armor_selected(consumption_handler, test_enchantment, armor_instance)
    else:
        print("No consumption handler returned!")

    print("=== TEST COMPLETE ===")
