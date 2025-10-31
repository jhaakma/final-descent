class_name ArmorResistanceUIIntegrationTest extends BaseTest

func test_status_effect_signals_emitted_on_armor_unequip() -> bool:
    # Create armor with fire resistance
    var armor := Armor.new()
    armor.name = "Signal Test Fire Armor"
    armor.defense_bonus = 0
    armor.armor_slot = Equippable.EquipSlot.CUIRASS
    armor.set_resistance(DamageType.Type.FIRE, true)

    # Reset player state
    var player := GameState.player
    player.reset()

    # Set up signal monitoring
    var signals_received := {
        "effect_removed": 0,
        "stats_changed": 0,
        "removed_condition_name": ""
    }

    # Connect to the status effect component's effect_removed signal
    player.status_effect_component.effect_removed.connect(
        func(condition_id: String) -> void:
            signals_received["effect_removed"] += 1
            signals_received["removed_condition_name"] = condition_id
    )

    # Connect to GameState.stats_changed signal
    GameState.stats_changed.connect(
        func() -> void:
            signals_received["stats_changed"] += 1
    )

    # Equip armor with resistance
    var armor_instance := ItemInstance.new(armor, null, 1)
    player.add_items(armor_instance)
    var equipped := player.equip_armor(armor_instance)

    if not equipped:
        return false

    # Verify resistance effect exists
    var has_resistance := player.is_resistant_to(DamageType.Type.FIRE)
    var has_status_effect := player.status_effect_component.active_conditions.has("Fire Resistance")

    if not has_resistance or not has_status_effect:
        return false

    # Reset signal counters
    signals_received["effect_removed"] = 0
    signals_received["stats_changed"] = 0

    # Now unequip armor
    var unequipped := player.unequip_armor(Equippable.EquipSlot.CUIRASS)

    if not unequipped:
        return false

    # Verify that signals were emitted
    if signals_received["effect_removed"] == 0:
        return false

    if signals_received["stats_changed"] == 0:
        return false

    # Verify the effect was actually removed
    var still_resistant := player.is_resistant_to(DamageType.Type.FIRE)
    var still_has_status_effect := player.status_effect_component.active_conditions.has("Fire Resistance")

    if still_resistant or still_has_status_effect:
        return false

    return true