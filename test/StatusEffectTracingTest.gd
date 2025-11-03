class_name StatusEffectTracingTest
extends BaseTest

func test_trace_status_effect_expiration() -> bool:
    # This will fail until CombatDebugger is implemented
    if not _has_class("CombatDebugger"):
        return false

    var debugger := _create_combat_debugger()
    if not debugger:
        return false

    # Set debug level to capture trace messages
    if not assert_has_method(debugger, "set_log_level", "CombatDebugger should have set_log_level method"):
        return false

    # Try to set debug level using LogLevel enum
    var log_level := _get_log_level_enum()
    if not log_level:
        return false

    debugger.call("set_log_level", log_level.get("DEBUG", 4))

    # Create a mock effect for testing
    var effect := create_test_status_effect()
    var logged_messages := []

    # Capture log output
    if _has_signal(debugger, "message_logged"):
        debugger.connect("message_logged", func(msg: Variant) -> void: logged_messages.append(msg))

    # Test tracing effect expiration
    if not assert_has_method(debugger, "trace_status_effect_expiration", "CombatDebugger should have trace_status_effect_expiration method"):
        return false

    # Mock EffectTiming.TURN_START for testing
    debugger.call("trace_status_effect_expiration", effect, EffectTiming.Type.TURN_START)

    return (assert_equals(logged_messages.size(), 1, "Should log one message") and
            assert_string_contains(logged_messages[0], "expired at 0", "Should contain timing information"))

func test_get_active_effects_summary() -> bool:
    # This will fail until CombatDebugger is implemented
    if not _has_class("CombatDebugger"):
        return false

    var debugger := _create_combat_debugger()
    if not debugger:
        return false

    var player := create_test_player_with_effects()

    if not assert_has_method(debugger, "get_active_effects_summary", "CombatDebugger should have get_active_effects_summary method"):
        return false

    var summary: String = debugger.call("get_active_effects_summary", player)

    # Debug output to see what we actually get
    print("=== DEBUG SUMMARY OUTPUT ===")
    print(summary)
    print("=== END DEBUG ===")

    # Should contain effect information
    return (assert_string_contains(summary, "Active Effects", "Summary should contain header") and
            assert_string_contains(summary, "Poison", "Summary should contain poison effect") and
            assert_string_contains(summary, "0", "Summary should contain timing information (TURN_START=0)") and
            assert_string_contains(summary, "Defend", "Summary should contain defend effect") and
            assert_string_contains(summary, "3", "Summary should contain defend timing (TURN_END=3)"))

func test_effect_expiration_timeline() -> bool:
    # This will fail until CombatDebugger is implemented
    if not _has_class("CombatDebugger"):
        return false

    var debugger := _create_combat_debugger()
    if not debugger:
        return false

    var player := create_test_player_with_timed_effects()

    if not assert_has_method(debugger, "get_effect_expiration_timeline", "CombatDebugger should have get_effect_expiration_timeline method"):
        return false

    var timeline: Array = debugger.call("get_effect_expiration_timeline", player)

    # Should return an array of timeline entries
    return (assert_true(timeline is Array, "Timeline should be an array") and
            assert_true(timeline.size() > 0, "Timeline should not be empty") and
            assert_string_contains(str(timeline), "Turn 1 3: Defend", "Timeline should show defend expiring at turn 1 with TURN_END(3)") and
            assert_string_contains(str(timeline), "Turn 2 0: Poison", "Timeline should show poison expiring at turn 2 with TURN_START(0)"))

func test_debugger_logs_effect_application() -> bool:
    # This will fail until CombatDebugger is implemented
    if not _has_class("CombatDebugger"):
        return false

    var debugger := _create_combat_debugger()
    if not debugger:
        return false

    # Set debug level
    var log_level := _get_log_level_enum()
    if not log_level:
        return false

    debugger.call("set_log_level", log_level.get("DEBUG", 4))

    var logged_messages := []
    if _has_signal(debugger, "message_logged"):
        debugger.connect("message_logged", func(msg: Variant) -> void: logged_messages.append(msg))

    # Test effect application tracing
    if not assert_has_method(debugger, "trace_status_effect_applied", "CombatDebugger should have trace_status_effect_applied method"):
        return false

    var effect := create_test_status_effect()
    var target := create_test_player()

    debugger.call("trace_status_effect_applied", effect, target)

    return (assert_equals(logged_messages.size(), 1, "Should log one message") and
            assert_string_contains(logged_messages[0], "applied to", "Should contain application information"))

func test_debugger_effect_summary_format() -> bool:
    # This will fail until CombatDebugger is implemented
    if not _has_class("CombatDebugger"):
        return false

    var debugger := _create_combat_debugger()
    if not debugger:
        return false

    var effect := create_test_status_effect()

    if not assert_has_method(debugger, "format_effect_info", "CombatDebugger should have format_effect_info method"):
        return false

    var formatted: String = debugger.call("format_effect_info", effect)

    # Should contain key effect information
    return (assert_string_contains(formatted, "Test Effect", "Should contain effect name") and
            assert_string_contains(formatted, "expires:", "Should contain expiration info") and
            assert_string_contains(formatted, "turns left:", "Should contain turn countdown"))

# Helper methods for testing
func _has_class(_class_name: String) -> bool:
    var script_path = "res://src/core/" + _class_name + ".gd"
    return ResourceLoader.exists(script_path)

func _create_combat_debugger() -> Object:
    if _has_class("CombatDebugger"):
        var script = load("res://src/core/CombatDebugger.gd")
        if script:
            return script.new()
    return null

func _get_log_level_enum() -> Dictionary:
    if _has_class("CombatDebugger"):
        var script: Script = load("res://src/core/CombatDebugger.gd")
        if script:
            # Try to get LogLevel enum - this will fail until implemented
            var constants: Dictionary = {}
            if script.has_method("get_script_constant_map"):
                constants = script.get_script_constant_map()
            return constants.get("LogLevel", {})
    return {}

func _has_signal(object: Object, signal_name: String) -> bool:
    if not object:
        return false
    var signals := object.get_signal_list()
    for signal_info in signals:
        if signal_info.get("name", "") == signal_name:
            return true
    return false

func create_test_status_effect() -> Dictionary:
    # Mock status effect for testing
    var effect := {}
    effect["name"] = "Test Effect"
    effect["expire_timing"] = EffectTiming.Type.TURN_START
    effect["expire_after_turns"] = 2
    effect["applied_turn"] = 1
    return effect

func create_test_player_with_effects() -> Dictionary:
    var player := {}
    player["name"] = "Test Player"
    player["current_hp"] = 100
    player["max_hp"] = 100

    # Mock effects array
    var effects := []

    # Poison effect expiring at TURN_START
    var poison := {}
    poison["name"] = "Poison"
    poison["expire_timing"] = EffectTiming.Type.TURN_START
    poison["expire_after_turns"] = 2  # Changed from 3 to 2 to match test expectation
    poison["applied_turn"] = 1
    effects.append(poison)

    # Defend effect expiring at TURN_END
    var defend := {}
    defend["name"] = "Defend"
    defend["expire_timing"] = EffectTiming.Type.TURN_END
    defend["expire_after_turns"] = 1
    defend["applied_turn"] = 1
    effects.append(defend)

    player["active_effects"] = effects
    return player

func create_test_player_with_timed_effects() -> Dictionary:
    var player := create_test_player_with_effects()
    # This uses the same structure but emphasizes timing for timeline tests
    return player

func create_test_player() -> Dictionary:
    var player := {}
    player["name"] = "Test Player"
    player["current_hp"] = 100
    player["max_hp"] = 100
    return player