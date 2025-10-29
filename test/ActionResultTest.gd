class_name ActionResultTest extends BaseTest
## Tests for ActionResult type-safe data class

func test_action_result_initialization() -> bool:
	print("Testing ActionResult initialization...")

	# Test default constructor
	var default_result := ActionResult.new()
	if default_result.action_type != ActionResult.ActionType.ATTACK:
		push_error("Default action type should be ATTACK")
		return false

	if default_result.success != false:
		push_error("Default success should be false")
		return false

	if default_result.damage_dealt != 0:
		push_error("Default damage should be 0")
		return false

	if default_result.should_end_turn != true:
		push_error("Default should_end_turn should be true")
		return false

	if default_result.combat_fled != false:
		push_error("Default combat_fled should be false")
		return false

	# Test parameterized constructor
	var custom_result := ActionResult.new(
		ActionResult.ActionType.DEFEND,
		true,
		25,
		"Custom message",
		false,
		true
	)

	if custom_result.action_type != ActionResult.ActionType.DEFEND:
		push_error("Custom action type should be DEFEND")
		return false

	if custom_result.success != true:
		push_error("Custom success should be true")
		return false

	if custom_result.damage_dealt != 25:
		push_error("Custom damage should be 25")
		return false

	if custom_result.message != "Custom message":
		push_error("Custom message should be 'Custom message'")
		return false

	if custom_result.should_end_turn != false:
		push_error("Custom should_end_turn should be false")
		return false

	if custom_result.combat_fled != true:
		push_error("Custom combat_fled should be true")
		return false

	print("✓ ActionResult initialization test passed")
	return true

func test_action_result_factory_methods() -> bool:
	print("Testing ActionResult factory methods...")

	# Test attack result factory
	var attack_result := ActionResult.create_attack_result(50)
	if attack_result.action_type != ActionResult.ActionType.ATTACK:
		push_error("Attack result should have ATTACK type")
		return false

	if not attack_result.success:
		push_error("Attack result should be successful")
		return false

	if attack_result.damage_dealt != 50:
		push_error("Attack result should have 50 damage")
		return false

	if not attack_result.should_end_turn:
		push_error("Attack result should end turn")
		return false

	if attack_result.combat_fled:
		push_error("Attack result should not flee combat")
		return false

	# Test defend result factory
	var defend_result := ActionResult.create_defend_result()
	if defend_result.action_type != ActionResult.ActionType.DEFEND:
		push_error("Defend result should have DEFEND type")
		return false

	if not defend_result.success:
		push_error("Defend result should be successful")
		return false

	if defend_result.damage_dealt != 0:
		push_error("Defend result should have 0 damage")
		return false

	if not defend_result.should_end_turn:
		push_error("Defend result should end turn")
		return false

	# Test flee success factory
	var flee_success := ActionResult.create_flee_success()
	if flee_success.action_type != ActionResult.ActionType.FLEE:
		push_error("Flee success should have FLEE type")
		return false

	if not flee_success.success:
		push_error("Flee success should be successful")
		return false

	if flee_success.should_end_turn:
		push_error("Flee success should not end turn (combat ends)")
		return false

	if not flee_success.combat_fled:
		push_error("Flee success should set combat_fled to true")
		return false

	# Test flee failure factory
	var flee_failure := ActionResult.create_flee_failure()
	if flee_failure.action_type != ActionResult.ActionType.FLEE:
		push_error("Flee failure should have FLEE type")
		return false

	if flee_failure.success:
		push_error("Flee failure should not be successful")
		return false

	if not flee_failure.should_end_turn:
		push_error("Flee failure should end turn")
		return false

	if flee_failure.combat_fled:
		push_error("Flee failure should not set combat_fled to true")
		return false

	# Test skip turn factory
	var skip_result := ActionResult.create_skip_turn()
	if skip_result.action_type != ActionResult.ActionType.SKIP:
		push_error("Skip result should have SKIP type")
		return false

	if not skip_result.success:
		push_error("Skip result should be successful")
		return false

	if not skip_result.should_end_turn:
		push_error("Skip result should end turn")
		return false

	print("✓ ActionResult factory methods test passed")
	return true

func test_action_result_get_action_name() -> bool:
	print("Testing ActionResult get_action_name...")

	var attack_result := ActionResult.create_attack_result(10)
	if attack_result.get_action_name() != "ATTACK":
		push_error("Attack result should return 'ATTACK' as name")
		return false

	var defend_result := ActionResult.create_defend_result()
	if defend_result.get_action_name() != "DEFEND":
		push_error("Defend result should return 'DEFEND' as name")
		return false

	var flee_result := ActionResult.create_flee_success()
	if flee_result.get_action_name() != "FLEE":
		push_error("Flee result should return 'FLEE' as name")
		return false

	var skip_result := ActionResult.create_skip_turn()
	if skip_result.get_action_name() != "SKIP":
		push_error("Skip result should return 'SKIP' as name")
		return false

	print("✓ ActionResult get_action_name test passed")
	return true