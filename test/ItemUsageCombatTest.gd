class_name ItemUsageCombatTest extends BaseTest

func test_scroll_usage_consumes_player_turn() -> bool:
    var test_name: String = "scroll usage consumes player turn"
    print("Testing %s..." % test_name)

    # Create a simple combat context
    var player := Player.new()
    var enemy_res := load("res://data/enemies/Goblin.tres") as EnemyResource
    var enemy := Enemy.new(enemy_res)
    var context := CombatContext.new(player, enemy, enemy_res)

    # Create state manager and processors
    var state_manager := CombatStateManager.new(context)
    var player_processor := PlayerTurnProcessor.new()

    # Start combat and ensure we're in player turn
    state_manager.start_combat()
    var initial_state := state_manager.get_current_state()
    if initial_state != CombatStateManager.State.PLAYER_TURN:
        state_manager.transition_to_player_turn()

    # Record initial enemy health (for potential future use)
    var _initial_enemy_hp := enemy.get_current_hp()

    # Execute item use action
    var result := player_processor.execute_action(PlayerTurnProcessor.PlayerAction.ITEM_USE, context)

    # Verify the result is correct type
    if result.action_type != ActionResult.ActionType.ITEM_USE:
        print("❌ FAILED: Expected ITEM_USE action type, got %s" % ActionResult.ActionType.keys()[result.action_type])
        return false

    # Verify the action should end the turn
    if not result.should_end_turn:
        print("❌ FAILED: Item usage should end the player's turn")
        return false

    # Verify the action was successful
    if not result.success:
        print("❌ FAILED: Item usage action should be successful")
        return false

    print("✓ %s test passed" % test_name.capitalize())
    return true

func test_fire_scroll_damages_enemy() -> bool:
    var test_name: String = "fire scroll damages enemy in combat"
    print("Testing %s..." % test_name)

    # Create combat context
    var player := Player.new()
    var enemy_res := load("res://data/enemies/Goblin.tres") as EnemyResource
    var enemy := Enemy.new(enemy_res)
    var _context := CombatContext.new(player, enemy, enemy_res)

    # Set up GameState for combat (needed for scroll to work)
    GameState.start_combat(enemy)

    # Get initial enemy health
    var initial_hp := enemy.get_current_hp()

    # Load and use fire scroll
    var fire_scroll_res := load("res://data/items/scrolls/ScrollOfFirebolt.tres") as Scroll
    var scroll := fire_scroll_res.duplicate() as Scroll

    # Simulate using the scroll (this should damage the enemy)
    var success := scroll._on_use(null)

    # Clean up GameState
    GameState.end_combat()

    # Verify scroll usage was successful
    if not success:
        print("❌ FAILED: Fire scroll usage should be successful")
        return false

    # Verify enemy took damage
    var final_hp := enemy.get_current_hp()
    if final_hp >= initial_hp:
        print("❌ FAILED: Enemy should have taken damage from fire scroll (initial: %d, final: %d)" % [initial_hp, final_hp])
        return false

    print("✓ %s test passed" % test_name.capitalize())
    print("  Enemy HP: %d -> %d (-%d damage)" % [initial_hp, final_hp, initial_hp - final_hp])
    return true