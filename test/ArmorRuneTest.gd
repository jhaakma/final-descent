class_name ArmorRuneTest extends BaseTest

func test_armor_rune_enchantment_application() -> bool:
    # Create test armor rune
    var armor_rune := ArmorRune.new()
    var test_enchantment := ConstantEffectEnchantment.new()
    armor_rune.armor_enchantment = test_enchantment

    # Create test armor
    var armor := Armor.new()
    armor.name = "Test Cuirass"
    armor.armor_slot = Equippable.EquipSlot.CUIRASS

    var item_data := ItemData.new()
    item_data.current_condition = 100

    var armor_instance := ItemInstance.new(armor, item_data, 1)

    # Set up item data for the rune
    var rune_item_data := ItemData.new()

    # Test the callback method directly with correct parameter order (selected_armor, enchantment, item_data)
    armor_rune._on_armor_selected(armor_instance, test_enchantment, rune_item_data)

    # Verify the armor was enchanted
    var enchanted_armor := armor_instance.item as Armor
    assert_not_null(enchanted_armor.enchantment, "Armor should have an enchantment")
    assert_equals(enchanted_armor.enchantment, test_enchantment, "Armor should have the correct enchantment")
    assert_true(enchanted_armor.name.contains("of"), "Armor name should include enchantment in name")

    # Verify that condition is preserved after enchantment
    assert_equals(armor_instance.item_data.current_condition, 100, "Armor condition should be preserved after enchantment")

    return true

func test_armor_rune_handles_async_completion() -> bool:
    # Create test armor rune
    var armor_rune := ArmorRune.new()
    var test_enchantment := ConstantEffectEnchantment.new()
    armor_rune.armor_enchantment = test_enchantment

    # Test that the rune indicates it handles async completion
    assert_true(armor_rune._handles_async_completion(), "ArmorRune should handle async completion")

    return true

func test_armor_rune_completion_signal() -> bool:
    # Create test armor rune
    var armor_rune := ArmorRune.new()
    var test_enchantment := ConstantEffectEnchantment.new()
    armor_rune.armor_enchantment = test_enchantment

    # Set up test data
    var rune_item_data := ItemData.new()

    # Create a signal tracker
    var signal_tracker := SignalTracker.new()

    # Connect to the signal
    armor_rune.item_action_completed.connect(signal_tracker.on_signal_emitted)

    # Test cancellation
    armor_rune._on_selection_cancelled(rune_item_data)

    # Verify signal was emitted with correct parameters
    assert_true(signal_tracker.was_emitted, "Signal should be emitted on cancellation")
    assert_false(signal_tracker.success, "Signal should indicate failure on cancellation")
    assert_equals(signal_tracker.data, rune_item_data, "Signal should pass correct item data")

    return true

func test_armor_condition_preserved_through_player_replacement() -> bool:
    # Set up a player with equipped armor
    var player := GameState.player

    # Clear any existing equipment first
    player.unequip_armor(Equippable.EquipSlot.CUIRASS)

    # Create test armor with specific condition
    var armor := Armor.new()
    armor.name = "Test Cuirass"
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.condition = 10  # Set the armor's base condition

    var item_data := ItemData.new(8)  # Armor with condition 8 (slightly damaged)
    var armor_instance := ItemInstance.new(armor, item_data, 1)

    # Add to inventory first, then equip
    player.add_items(armor_instance)
    print("DEBUG: Equipping armor with condition: %d" % item_data.current_condition)
    var equip_success := player.equip_armor(armor_instance)
    print("DEBUG: Equip success: %s" % str(equip_success))

    # Create enchanted version
    var enchanted_armor := armor.duplicate() as Armor
    var test_enchantment := ConstantEffectEnchantment.new()
    enchanted_armor.enchantment = test_enchantment
    enchanted_armor.name = "Test Cuirass of Testing"

    # Get the equipped armor instance
    print("DEBUG: Getting equipped armor instance")
    var equipped_instance: ItemInstance = player.equipped_items[Equippable.EquipSlot.CUIRASS]
    print("DEBUG: Equipped instance: %s" % str(equipped_instance))
    var original_condition: int = equipped_instance.item_data.current_condition
    print("DEBUG: Original condition: %d" % original_condition)

    # Replace the armor through the player (simulating the enchantment process)
    var success := player.replace_item_instance(equipped_instance, enchanted_armor)

    # Verify the replacement succeeded
    assert_true(success, "Armor replacement should succeed")

    # Check that the equipped armor is now enchanted
    var new_equipped: ItemInstance = player.equipped_items[Equippable.EquipSlot.CUIRASS]
    var new_armor := new_equipped.item as Armor
    assert_not_null(new_armor.enchantment, "New armor should be enchanted")

    # CRITICAL TEST: Verify condition is preserved
    print("Original condition: %d, New condition: %d" % [original_condition, new_equipped.item_data.current_condition])
    assert_equals(new_equipped.item_data.current_condition, original_condition,
                 "Armor condition should be preserved after enchantment (was %d, now %d)" % [original_condition, new_equipped.item_data.current_condition])

    return true

# Helper class for tracking signals in tests
class SignalTracker:
    var was_emitted: bool = false
    var success: bool = false
    var data: ItemData = null

    func on_signal_emitted(signal_success: bool, signal_data: ItemData) -> void:
        was_emitted = true
        success = signal_success
        data = signal_data
