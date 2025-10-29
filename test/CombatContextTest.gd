class_name CombatContextTest extends BaseTest
## Tests for CombatContext data container

func test_combat_context_initialization() -> bool:
	print("Testing CombatContext initialization...")

	# Create test entities
	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 30
	enemy_resource.attack = 5
	enemy_resource.defense = 10
	var enemy := Enemy.new(enemy_resource)

	# Create context
	var context := CombatContext.new(player, enemy, enemy_resource)

	# Test initialization values
	if context.player != player:
		push_error("Player not set correctly")
		return false

	if context.enemy != enemy:
		push_error("Enemy not set correctly")
		return false

	if context.enemy_resource != enemy_resource:
		push_error("Enemy resource not set correctly")
		return false

	if context.is_combat_active != true:
		push_error("Combat should be active on initialization")
		return false

	if context.turn_count != 0:
		push_error("Turn count should start at 0")
		return false

	print("✓ CombatContext initialization test passed")
	return true

func test_combat_context_state_management() -> bool:
	print("Testing CombatContext state management...")

	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 30
	var enemy := Enemy.new(enemy_resource)

	var context := CombatContext.new(player, enemy, enemy_resource)

	# Test setting enemy first
	context.set_enemy_first(true)
	if context.enemy_first != true:
		push_error("Enemy first not set correctly")
		return false

	# Test setting avoid failure
	context.set_avoid_failure(true)
	if context.avoid_failure != true:
		push_error("Avoid failure not set correctly")
		return false

	# Test turn increment
	var signal_received := [false]  # Use array to allow mutation in lambda
	context.context_changed.connect(func()->void: signal_received[0] = true)

	context.increment_turn()
	if context.turn_count != 1:
		push_error("Turn count should be 1 after increment")
		return false

	if not signal_received[0]:
		push_error("Context changed signal should have been emitted")
		return false

	print("✓ CombatContext state management test passed")
	return true

func test_combat_context_end_conditions() -> bool:
	print("Testing CombatContext end conditions...")

	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 30
	var enemy := Enemy.new(enemy_resource)

	var context := CombatContext.new(player, enemy, enemy_resource)

	# Test initial state
	if not context.is_player_alive():
		push_error("Player should be alive initially")
		return false

	if not context.is_enemy_alive():
		push_error("Enemy should be alive initially")
		return false

	if context.is_combat_over():
		push_error("Combat should not be over initially")
		return false

	if context.get_combat_winner() != "none":
		push_error("There should be no winner initially")
		return false

	# Test player death
	player.take_damage(1000)  # Kill player
	if context.is_player_alive():
		push_error("Player should be dead after massive damage")
		return false

	if not context.is_combat_over():
		push_error("Combat should be over when player dies")
		return false

	if context.get_combat_winner() != "enemy":
		push_error("Enemy should be winner when player dies")
		return false

	# Reset and test enemy death
	player.heal(1000)  # Revive player
	enemy.take_damage(1000)  # Kill enemy

	if context.is_enemy_alive():
		push_error("Enemy should be dead after massive damage")
		return false

	if not context.is_combat_over():
		push_error("Combat should be over when enemy dies")
		return false

	if context.get_combat_winner() != "player":
		push_error("Player should be winner when enemy dies")
		return false

	# Test end combat
	context.end_combat()
	if context.is_combat_active:
		push_error("Combat should be inactive after end_combat()")
		return false

	print("✓ CombatContext end conditions test passed")
	return true