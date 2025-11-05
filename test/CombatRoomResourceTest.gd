extends BaseTest
class_name CombatRoomResourceTest

## Test CombatRoomResource functionality with enemy generators

func test_combat_room_with_enemy_list() -> bool:
    print("Testing CombatRoomResource with enemy list...")

    # Create a combat room with enemy list
    var combat_room := CombatRoomResource.new()

    # Create test enemies
    var goblin := EnemyResource.new()
    goblin.name = "Test Goblin"
    goblin.max_hp = 30
    goblin.attack = 5
    goblin.avoid_chance = 0.5

    var orc := EnemyResource.new()
    orc.name = "Test Orc"
    orc.max_hp = 40
    orc.attack = 7
    orc.avoid_chance = 0.3

    combat_room.enemy_list = [goblin, orc]

    # Create mock components for build_actions
    var actions_grid := GridContainer.new()
    var room_screen := RoomScreen.new()

    # This should work without errors
    combat_room.build_actions(actions_grid, room_screen)

    # Should have selected an enemy
    if not combat_room.selected_enemy:
        print("Expected selected_enemy to be set")
        return false

    # Should be one of our test enemies
    if combat_room.selected_enemy.name != "Test Goblin" and combat_room.selected_enemy.name != "Test Orc":
        print("Expected selected enemy to be either Test Goblin or Test Orc, got: ", combat_room.selected_enemy.name)
        return false

    actions_grid.queue_free()
    room_screen.queue_free()

    print("CombatRoomResource with enemy list test passed")
    return true

func test_combat_room_empty_configuration() -> bool:
    print("Testing CombatRoomResource with empty configuration...")

    # Create a combat room with no enemies or generator
    var combat_room := CombatRoomResource.new()

    # Create mock components
    var actions_grid := GridContainer.new()
    var room_screen := RoomScreen.new()

    # This should handle the error gracefully
    combat_room.build_actions(actions_grid, room_screen)

    # Should not have selected an enemy
    if combat_room.selected_enemy:
        print("Expected no selected_enemy with empty configuration")
        return false

    actions_grid.queue_free()
    room_screen.queue_free()

    print("CombatRoomResource empty configuration test passed")
    return true