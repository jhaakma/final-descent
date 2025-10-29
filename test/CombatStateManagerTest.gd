class_name CombatStateManagerTest extends BaseTest
## Tests for CombatStateManager state machine

## Helper class to track signal emissions without lambda typing issues
class SignalTracker extends RefCounted:
	var state_changed_received := false
	var combat_started_received := false
	var player_turn_started_received := false
	var enemy_turn_started_received := false
	var turn_ended_received := false
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

	func on_turn_ended(_context) -> void:
		turn_ended_received = true

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

	if state_manager.get_current_state() != CombatStateManager.State.COMBAT_START:
		push_error("Initial state should be COMBAT_START")
		return false

	if state_manager.context != context:
		push_error("Context should be set correctly")
		return false

	print("✓ CombatStateManager initialization test passed")
	return true

func test_state_transitions() -> bool:
	print("Testing CombatStateManager state transitions...")

	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 30
	var enemy := Enemy.new(enemy_resource)
	var context := CombatContext.new(player, enemy, enemy_resource)

	var state_manager := CombatStateManager.new(context)

	# Test manual transition to player turn
	state_manager.transition_to_player_turn()
	if state_manager.get_current_state() != CombatStateManager.State.PLAYER_TURN:
		push_error("Should transition to PLAYER_TURN")
		return false

	# Test transition to turn end from player turn
	# This should automatically transition to enemy turn since combat is ongoing
	state_manager.transition_to_turn_end()
	if state_manager.get_current_state() != CombatStateManager.State.ENEMY_TURN:
		push_error("Should automatically transition to ENEMY_TURN after player turn end")
		return false

	# Test manual transition to combat end
	state_manager.end_combat(true)
	if state_manager.get_current_state() != CombatStateManager.State.COMBAT_END:
		push_error("Should transition to COMBAT_END")
		return false

	print("✓ CombatStateManager state transitions test passed")
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

	state_manager.state_changed.connect(tracker.on_state_changed)
	state_manager.combat_started.connect(tracker.on_combat_started)
	state_manager.player_turn_started.connect(tracker.on_player_turn_started)
	state_manager.enemy_turn_started.connect(tracker.on_enemy_turn_started)
	state_manager.turn_ended.connect(tracker.on_turn_ended)
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

	# To test enemy turn, we need to go through TURN_END first, or start with enemy first
	# Let's test by going through proper flow: PLAYER_TURN -> TURN_END -> ENEMY_TURN
	tracker.turn_ended_received = false
	tracker.enemy_turn_started_received = false
	state_manager.transition_to_turn_end()  # This will auto-transition to enemy turn

	if not tracker.turn_ended_received:
		push_error("turn_ended signal should have been emitted")
		return false

	if not tracker.enemy_turn_started_received:
		push_error("enemy_turn_started signal should have been emitted after turn end")
		return false

	# Test combat end signal
	tracker.combat_ended_received = false
	state_manager.end_combat(true)
	if not tracker.combat_ended_received:
		push_error("combat_ended signal should have been emitted")
		return false

	print("✓ CombatStateManager signal emissions test passed")
	return true

func test_invalid_state_transitions() -> bool:
	print("Testing CombatStateManager invalid state transitions...")

	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 30
	var enemy := Enemy.new(enemy_resource)
	var context := CombatContext.new(player, enemy, enemy_resource)

	var state_manager := CombatStateManager.new(context)

	# End combat first
	state_manager.end_combat(true)
	var final_state := state_manager.get_current_state()

	# Try to transition from terminal state - should not work
	state_manager.transition_to_player_turn()
	if state_manager.get_current_state() != final_state:
		push_error("Should not be able to transition from COMBAT_END state")
		return false

	state_manager.transition_to_enemy_turn()
	if state_manager.get_current_state() != final_state:
		push_error("Should not be able to transition from COMBAT_END state")
		return false

	print("✓ CombatStateManager invalid state transitions test passed")
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

	# The state manager should detect combat end when transition_to_turn_end is called
	# since _check_combat_end_conditions is called within transition_to_turn_end
	state_manager.transition_to_turn_end()

	if not tracker.combat_ended_received:
		push_error("Combat should have ended automatically when enemy died")
		return false

	if not tracker.victory_result:
		push_error("Should have been a victory when enemy died")
		return false

	if state_manager.get_current_state() != CombatStateManager.State.COMBAT_END:
		push_error("State should be COMBAT_END after automatic end")
		return false

	print("✓ CombatStateManager automatic combat end test passed")
	return true