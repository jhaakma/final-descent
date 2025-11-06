class_name CombatStateManagerTest extends BaseTest
## Tests for CombatStateManager state machine

## Helper class to track signal emissions without lambda typing issues
class SignalTracker extends RefCounted:
    var state_changed_received := false
    var combat_started_received := false
    var player_turn_started_received := false
    var enemy_turn_started_received := false
    var round_ended_received := false
    var combat_ended_received := false
    var victory_result := false

    func on_state_changed(_state, _context) -> void:
        state_changed_received = true

    func on_combat_started(_context) -> void:
        combat_started_received = true

    func on_player_turn_started(_context) -> void:
        player_turn_started_received = true

    func on_enemy_turn_started(_context) -> void:
        enemy_turn_started_received = true

    func on_round_ended(_context) -> void:
        round_ended_received = true

    func on_combat_ended(_context, victory) -> void:
        combat_ended_received = true
        victory_result = victory

func test_state_manager_initialization() -> bool:
    print("Testing CombatStateManager initialization...")

    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 30
    var enemy := Enemy.new(enemy_resource)
    var context := CombatContext.new(player, enemy, enemy_resource)

    var state_manager := CombatStateManager.new(context)

    if state_manager.context != context:
        push_error("Context should be set correctly")
        return false

    print("✓ CombatStateManager initialization test passed")
    return true


func test_signal_emissions() -> bool:
    print("Testing CombatStateManager signal emissions...")

    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 30
    var enemy := Enemy.new(enemy_resource)
    var context := CombatContext.new(player, enemy, enemy_resource)

    var state_manager := CombatStateManager.new(context)

    # Use a signal tracker class to avoid lambda typing issues
    var tracker := SignalTracker.new()

    state_manager.combat_started.connect(tracker.on_combat_started)
    state_manager.player_turn_started.connect(tracker.on_player_turn_started)
    state_manager.enemy_turn_started.connect(tracker.on_enemy_turn_started)
    state_manager.round_ended.connect(tracker.on_round_ended)
    state_manager.combat_ended.connect(tracker.on_combat_ended)

    # Test start combat signal - this will automatically start first turn
    state_manager.start_combat()

    if not tracker.combat_started_received:
        push_error("combat_started signal should have been emitted")
        return false

    # start_combat() automatically transitions to first turn (player by default)
    if not tracker.player_turn_started_received:
        push_error("player_turn_started signal should have been emitted (default first turn)")
        return false

    # To test enemy turn, we need to end the player turn
    tracker.round_ended_received = false
    tracker.enemy_turn_started_received = false
    state_manager.end_player_turn()  # This transitions to enemy turn

    if not tracker.enemy_turn_started_received:
        push_error("enemy_turn_started signal should have been emitted after player turn end")
        return false

    # End enemy turn to complete the round
    state_manager.end_enemy_turn()  # This completes the round and starts next round

    if not tracker.round_ended_received:
        push_error("round_ended signal should have been emitted")
        return false

    # Test combat end signal
    tracker.combat_ended_received = false
    state_manager.end_combat(true)
    if not tracker.combat_ended_received:
        push_error("combat_ended signal should have been emitted")
        return false

    print("✓ CombatStateManager signal emissions test passed")
    return true

func test_automatic_combat_end() -> bool:
    print("Testing CombatStateManager automatic combat end...")

    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 30
    var enemy := Enemy.new(enemy_resource)
    var context := CombatContext.new(player, enemy, enemy_resource)

    var state_manager := CombatStateManager.new(context)

    var tracker := SignalTracker.new()
    state_manager.combat_ended.connect(tracker.on_combat_ended)

    # Start combat and move to a valid state first
    state_manager.start_combat()  # This moves to PLAYER_TURN

    # Kill the enemy
    enemy.take_damage(1000)

    # The state manager should detect combat end when end_current_turn is called
    # since _check_combat_end_conditions is called within end_current_turn
    state_manager.end_player_turn()

    if not tracker.combat_ended_received:
        push_error("Combat should have ended automatically when enemy died")
        return false

    if not tracker.victory_result:
        push_error("Should have been a victory when enemy died")
        return false

    print("✓ CombatStateManager automatic combat end test passed")
    return true