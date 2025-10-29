class_name PlayerTurnProcessorTest extends BaseTest
## Tests for PlayerTurnProcessor logic

func test_player_turn_processor_attack() -> bool:
	print("Testing PlayerTurnProcessor attack action...")

	# Create test setup
	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 100
	enemy_resource.attack = 5
	enemy_resource.defense = 10
	var enemy := Enemy.new(enemy_resource)
	var context := CombatContext.new(player, enemy, enemy_resource)

	var processor := PlayerTurnProcessor.new()

	# Record initial enemy HP
	var initial_enemy_hp := enemy.get_current_hp()

	# Execute attack
	var result := processor.execute_action(PlayerTurnProcessor.PlayerAction.ATTACK, context)

	# Verify result type and success
	if result.action_type != ActionResult.ActionType.ATTACK:
		push_error("Attack result should have ATTACK type")
		return false

	if not result.success:
		push_error("Attack should be successful")
		return false

	if result.damage_dealt <= 0:
		push_error("Attack should deal some damage")
		return false

	if not result.should_end_turn:
		push_error("Attack should end player turn")
		return false

	if result.combat_fled:
		push_error("Attack should not set combat_fled")
		return false

	# Verify enemy took damage
	if enemy.get_current_hp() >= initial_enemy_hp:
		push_error("Enemy should have taken damage")
		return false

	var expected_damage := initial_enemy_hp - enemy.get_current_hp()
	if result.damage_dealt != expected_damage:
		push_error("Result damage should match actual damage dealt")
		return false

	print("✓ PlayerTurnProcessor attack test passed")
	return true

func test_player_turn_processor_defend() -> bool:
	print("Testing PlayerTurnProcessor defend action...")

	# Create test setup
	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 100
	var enemy := Enemy.new(enemy_resource)
	var context := CombatContext.new(player, enemy, enemy_resource)

	var processor := PlayerTurnProcessor.new()

	# Execute defend
	var result := processor.execute_action(PlayerTurnProcessor.PlayerAction.DEFEND, context)

	# Verify result type and success
	if result.action_type != ActionResult.ActionType.DEFEND:
		push_error("Defend result should have DEFEND type")
		return false

	if not result.success:
		push_error("Defend should be successful")
		return false

	if result.damage_dealt != 0:
		push_error("Defend should not deal damage")
		return false

	if not result.should_end_turn:
		push_error("Defend should end player turn")
		return false

	if result.combat_fled:
		push_error("Defend should not set combat_fled")
		return false

	# Verify player has defend effect (this tests the DefendAbility integration)
	if not player.has_status_effect("defend"):
		push_error("Player should have defend status effect after defending")
		return false

	print("✓ PlayerTurnProcessor defend test passed")
	return true

func test_player_turn_processor_flee_success() -> bool:
	print("Testing PlayerTurnProcessor flee success...")

	# Create test setup with guaranteed flee success
	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 100
	enemy_resource.avoid_chance = 1.0  # 100% flee chance
	var enemy := Enemy.new(enemy_resource)
	var context := CombatContext.new(player, enemy, enemy_resource)

	var processor := PlayerTurnProcessor.new()

	# Execute flee
	var result := processor.execute_action(PlayerTurnProcessor.PlayerAction.FLEE, context)

	# Verify result type and success
	if result.action_type != ActionResult.ActionType.FLEE:
		push_error("Flee result should have FLEE type")
		return false

	if not result.success:
		push_error("Flee should be successful with 100% chance")
		return false

	if result.damage_dealt != 0:
		push_error("Flee should not deal damage")
		return false

	if result.should_end_turn:
		push_error("Successful flee should not end turn (combat ends)")
		return false

	if not result.combat_fled:
		push_error("Successful flee should set combat_fled to true")
		return false

	print("✓ PlayerTurnProcessor flee success test passed")
	return true

func test_player_turn_processor_flee_failure() -> bool:
	print("Testing PlayerTurnProcessor flee failure...")

	# Create test setup with guaranteed flee failure
	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 100
	enemy_resource.avoid_chance = 0.0  # 0% flee chance
	var enemy := Enemy.new(enemy_resource)
	var context := CombatContext.new(player, enemy, enemy_resource)

	var processor := PlayerTurnProcessor.new()

	# Execute flee
	var result := processor.execute_action(PlayerTurnProcessor.PlayerAction.FLEE, context)

	# Verify result type and failure
	if result.action_type != ActionResult.ActionType.FLEE:
		push_error("Flee result should have FLEE type")
		return false

	if result.success:
		push_error("Flee should fail with 0% chance")
		return false

	if result.damage_dealt != 0:
		push_error("Failed flee should not deal damage")
		return false

	if not result.should_end_turn:
		push_error("Failed flee should end turn")
		return false

	if result.combat_fled:
		push_error("Failed flee should not set combat_fled to true")
		return false

	print("✓ PlayerTurnProcessor flee failure test passed")
	return true

func test_player_turn_processor_can_process_turn() -> bool:
	print("Testing PlayerTurnProcessor can_process_turn...")

	# Create test setup
	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 100
	var enemy := Enemy.new(enemy_resource)
	var context := CombatContext.new(player, enemy, enemy_resource)

	var processor := PlayerTurnProcessor.new()

	# Test normal conditions - should be able to process
	if not processor.can_process_turn(context):
		push_error("Should be able to process turn under normal conditions")
		return false

	# Test dead player - should not be able to process
	player.take_damage(1000)  # Kill player
	if processor.can_process_turn(context):
		push_error("Should not be able to process turn when player is dead")
		return false

	# Reset player and test stunned player
	player.heal(1000)  # Revive player

	# Apply stun effect to player (this tests the integration with status effects)
	var stun_effect := StunEffect.new()
	stun_effect.duration = 1
	player.apply_status_effect(stun_effect)

	if processor.can_process_turn(context):
		push_error("Should not be able to process turn when player is stunned")
		return false

	print("✓ PlayerTurnProcessor can_process_turn test passed")
	return true

func test_player_turn_processor_signal_emission() -> bool:
	print("Testing PlayerTurnProcessor signal emission...")

	# Create test setup
	var player := Player.new()
	var enemy_resource := EnemyResource.new()
	enemy_resource.name = "Test Goblin"
	enemy_resource.max_hp = 100
	var enemy := Enemy.new(enemy_resource)
	var context := CombatContext.new(player, enemy, enemy_resource)

	var processor := PlayerTurnProcessor.new()

	# Track signal emission
	var signal_received := [false]
	var received_result := [null]

	processor.turn_action_executed.connect(func(action_result)->void:
		signal_received[0] = true
		received_result[0] = action_result
	)

	# Execute action
	var result := processor.execute_action(PlayerTurnProcessor.PlayerAction.ATTACK, context)

	# Verify signal was emitted
	if not signal_received[0]:
		push_error("turn_action_executed signal should have been emitted")
		return false

	if received_result[0] != result:
		push_error("Signal should have passed the same ActionResult")
		return false

	print("✓ PlayerTurnProcessor signal emission test passed")
	return true