class_name PlayerTurnProcessorTest extends BaseTest
## Tests for CombatStateManager player action logic

func test_player_turn_processor_attack() -> bool:
    print("Testing CombatStateManager attack action...")

    # Create test setup
    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 100
    enemy_resource.attack = 5
    enemy_resource.defense = 10
    var enemy := Enemy.new(enemy_resource)
    var context := CombatContext.new(player, enemy, enemy_resource)

    var state_manager := CombatStateManager.new(context)

    # Record initial enemy HP
    var initial_enemy_hp := enemy.get_current_hp()

    # Execute attack
    var result := state_manager.execute_player_action(CombatStateManager.PlayerAction.ATTACK)

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

    print("✓ CombatStateManager attack test passed")
    return true

func test_player_turn_processor_defend() -> bool:
    print("Testing CombatStateManager defend action...")

    # Create test setup
    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 100
    var enemy := Enemy.new(enemy_resource)
    var context := CombatContext.new(player, enemy, enemy_resource)

    var state_manager := CombatStateManager.new(context)

    # Execute defend
    var result := state_manager.execute_player_action(CombatStateManager.PlayerAction.DEFEND)

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

    print("✓ CombatStateManager defend test passed")
    return true

func test_player_turn_processor_flee_success() -> bool:
    print("Testing CombatStateManager flee success...")

    # Create test setup with guaranteed flee success
    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 100
    enemy_resource.avoid_chance = 1.0  # 100% flee chance
    var enemy := Enemy.new(enemy_resource)
    var context := CombatContext.new(player, enemy, enemy_resource)

    var state_manager := CombatStateManager.new(context)

    # Execute flee
    var result := state_manager.execute_player_action(CombatStateManager.PlayerAction.FLEE)

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

    print("✓ CombatStateManager flee success test passed")
    return true

func test_player_turn_processor_flee_failure() -> bool:
    print("Testing CombatStateManager flee failure...")

    # Create test setup with guaranteed flee failure
    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 100
    enemy_resource.avoid_chance = 0.0  # 0% flee chance
    var enemy := Enemy.new(enemy_resource)
    var context := CombatContext.new(player, enemy, enemy_resource)

    var state_manager := CombatStateManager.new(context)

    # Execute flee
    var result := state_manager.execute_player_action(CombatStateManager.PlayerAction.FLEE)

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

    print("✓ CombatStateManager flee failure test passed")
    return true

func test_player_turn_processor_can_process_turn() -> bool:
    print("Testing player turn processing conditions...")

    # Create test setup
    var player := Player.new()
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Goblin"
    enemy_resource.max_hp = 100
    var enemy := Enemy.new(enemy_resource)
    var context := CombatContext.new(player, enemy, enemy_resource)

    # Test normal conditions - player is alive and not stunned
    if not context.is_player_alive():
        push_error("Player should be alive under normal conditions")
        return false

    if player.should_skip_turn():
        push_error("Player should not skip turn under normal conditions")
        return false

    # Test dead player
    player.take_damage(1000)  # Kill player
    if context.is_player_alive():
        push_error("Player should be dead after taking lethal damage")
        return false

    # Reset player and test stunned player
    player.heal(1000)  # Revive player

    # Apply stun effect to player
    var stun_effect := StunEffect.new()
    stun_effect.set_expire_after_turns(1)
    player.apply_status_effect(stun_effect)

    if not player.should_skip_turn():
        push_error("Player should skip turn when stunned")
        return false

    print("✓ Player turn processing conditions test passed")
    return true