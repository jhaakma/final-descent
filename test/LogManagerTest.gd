# Test script for the new LogManager functionality
class_name LogManagerTest extends BaseTest

func test_basic_logging() -> bool:
    var log_manager := LogManager
    log_manager.clear_log_history()

    # Test basic message
    log_manager.log_event("Basic test message")

    var history := log_manager.get_log_history()
    assert_equals(history.size(), 1, "Should have one log entry")
    assert_equals(history[0].rich_text, "Basic test message", "Should match basic message")

    return true

func test_player_coloring() -> bool:
    var log_manager := LogManager
    log_manager.clear_log_history()

    # Test player coloring
    log_manager.log_event("{player:You} attack the enemy!")

    var history := log_manager.get_log_history()
    var expected := "[color=#4a90e2ff]You[/color] attack the enemy!"
    assert_equals(history[0].rich_text, expected, "Should color player text blue")

    return true

func test_damage_coloring() -> bool:
    var log_manager := LogManager
    log_manager.clear_log_history()

    # Test damage coloring with context
    log_manager.log_event("You deal {damage}!", {
        "damage_type": DamageType.Type.FIRE,
        "initial_damage": 15,
        "final_damage": 15
    })

    var history := log_manager.get_log_history()
    var fire_color := DamageType.get_type_color(DamageType.Type.FIRE).to_html()
    var expected := "You deal [color=%s]15 Fire damage[/color]!" % [fire_color]
    assert_equals(history[0].rich_text, expected, "Should color fire damage appropriately")

    return true

func test_damage_with_blocked() -> bool:
    var log_manager := LogManager
    log_manager.clear_log_history()

    # Test damage with blocked amount
    log_manager.log_event("You deal {damage}!", {
        "damage_type": DamageType.Type.FIRE,
        "initial_damage": 20,
        "final_damage": 15
    })

    var history := log_manager.get_log_history()
    var fire_color := DamageType.get_type_color(DamageType.Type.FIRE).to_html()
    var expected := "You deal [color=%s]15 Fire damage (blocked 5)[/color]!" % [fire_color]
    assert_equals(history[0].rich_text, expected, "Should show blocked damage when initial > final")

    return true

func test_healing_coloring() -> bool:
    var log_manager := LogManager
    log_manager.clear_log_history()

    # Test healing coloring
    log_manager.log_event("You heal {healing:20}!")

    var history := log_manager.get_log_history()
    var expected := "You heal [color=#a1f7afff]20[/color] HP!"
    assert_equals(history[0].rich_text, expected, "Should color healing green")

    return true

func test_pronoun_replacement() -> bool:
    var log_manager := LogManager
    log_manager.clear_log_history()

    # Test pronoun replacement with player target (should be blue)
    log_manager.log_event("{You} take damage!", {"target": GameState.player})

    var history := log_manager.get_log_history()
    var expected := "[color=#4a90e2ff]You[/color] take damage!"
    assert_equals(history[0].rich_text, expected, "Should replace {You} with colored You for player")

    return true