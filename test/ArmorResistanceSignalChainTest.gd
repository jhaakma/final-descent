extends BaseTest
class_name ArmorResistanceSignalChainTest

func test_signal_chain_from_unequip_to_ui_refresh() -> bool:
    """Test the complete signal chain from armor unequip to UI refresh

    This test monitors every step of the signal chain to find where it breaks:
    1. armor unequip -> StatusEffectComponent.effect_removed
    2. armor unequip -> GameState.stats_changed
    3. GameState.stats_changed -> RoomScreen._on_stats_changed
    4. RoomScreen._on_stats_changed -> RoomScreen._refresh_buffs
    """
    print("=== Testing Complete Signal Chain ===")

    # Reset player state
    var player := GameState.player
    player.reset()

    print("Player reset, initial status conditions: ", player.status_effect_component.active_conditions.size())

    # Create a RoomScreen to monitor
    var room_screen := RoomScreen.new()
    room_screen.buffs_block = VBoxContainer.new()

    # Track all signal calls
    var signal_chain := {
        "effect_removed_signal": 0,
        "stats_changed_signal": 0,
        "removed_condition_name": ""
    }

    # Connect to StatusEffectComponent.effect_removed
    var effect_removed_connection := player.status_effect_component.effect_removed.connect(
        func(condition_name: String) -> void:
            print("✓ StatusEffectComponent.effect_removed emitted for: ", condition_name)
            signal_chain["effect_removed_signal"] += 1
            signal_chain["removed_condition_name"] = condition_name
    )
    print("Connected to effect_removed signal: ", effect_removed_connection == OK)

    # Connect to GameState.stats_changed
    var stats_connection := GameState.stats_changed.connect(
        func() -> void:
            print("✓ GameState.stats_changed emitted")
            signal_chain["stats_changed_signal"] += 1
    )
    print("Connected to stats_changed signal: ", stats_connection == OK)

    # Note: We can't easily monitor _on_stats_changed and _refresh_buffs calls
    # without modifying the RoomScreen class, so we'll focus on signal emission

    # Create and equip fire-resistant armor
    var armor := create_fire_resistant_armor()
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)

    # Reset counters before the test
    signal_chain["effect_removed_signal"] = 0
    signal_chain["stats_changed_signal"] = 0

    var equipped := player.equip_armor(armor_instance)
    print("Equipped armor: ", equipped)

    if not equipped:
        print("Failed to equip armor")
        return false

    # Reset counters again for the unequip test
    signal_chain["effect_removed_signal"] = 0
    signal_chain["stats_changed_signal"] = 0

    print("\n--- Starting Unequip Test ---")
    print("Before unequip - signal chain state:")
    print("  effect_removed_signal: ", signal_chain["effect_removed_signal"])
    print("  stats_changed_signal: ", signal_chain["stats_changed_signal"])

    # Now unequip armor and monitor the signal chain
    print("\nUnequipping armor...")
    var unequipped := player.unequip_armor(Equippable.EquipSlot.CUIRASS)
    print("Unequipped armor: ", unequipped)

    if not unequipped:
        print("Failed to unequip armor")
        return false

    print("\nAfter unequip - signal chain state:")
    print("  effect_removed_signal: ", signal_chain["effect_removed_signal"])
    print("  stats_changed_signal: ", signal_chain["stats_changed_signal"])
    print("  removed_condition_name: ", signal_chain["removed_condition_name"])

    # Analyze where the chain breaks
    var chain_broken := false

    if signal_chain["effect_removed_signal"] == 0:
        print("❌ CHAIN BROKEN: StatusEffectComponent.effect_removed was NOT emitted")
        chain_broken = true

    if signal_chain["stats_changed_signal"] == 0:
        print("❌ CHAIN BROKEN: GameState.stats_changed was NOT emitted")
        chain_broken = true

    if not chain_broken:
        print("✅ Both required signals are being emitted correctly!")
        print("   The signal chain is working at the emission level.")
        print("   If UI bug still exists, it's likely in RoomScreen connection or timing.")
        return true
    else:
        print("🐛 Signal emission is broken - this explains the UI bug!")
        return false

func create_fire_resistant_armor() -> Armor:
    """Create armor with fire resistance"""
    var armor := Armor.new()
    armor.name = "Fire Resistant Cuirass"
    armor.defense_bonus = 0
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.set_resistance(DamageType.Type.FIRE, true)

    return armor
