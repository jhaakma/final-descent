extends RefCounted

# Quick test for defend effect timing

func _init() -> void:
    print("=== DEFEND TIMING TEST ===")

    # Create a player
    var player := Player.new()

    # Create a defend effect
    var defend_effect := DefendEffect.new(50)
    print("Defend effect expire timing: ", defend_effect.get_expire_timing())
    print("Expected TURN_START (1): ", EffectTiming.Type.TURN_START)

    # Apply defend effect
    var applied := player.apply_status_effect(defend_effect)
    print("Defend effect applied: ", applied)
    print("Player has defend effect: ", player.has_status_effect("defend"))

    # Test timing processing
    print("\n--- Processing ROUND_START (should not expire) ---")
    player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, 1)
    print("Player has defend effect after ROUND_START: ", player.has_status_effect("defend"))

    print("\n--- Processing TURN_START round 1 (should not expire yet) ---")
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 1)
    print("Player has defend effect after TURN_START round 1: ", player.has_status_effect("defend"))

    print("\n--- Processing TURN_START round 2 (should expire) ---")
    player.process_status_effects_at_timing(EffectTiming.Type.TURN_START, 2)
    print("Player has defend effect after TURN_START round 2: ", player.has_status_effect("defend"))

    print("=== END TEST ===")
