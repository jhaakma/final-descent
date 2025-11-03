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

func test_combat_room_with_enemy_generator() -> bool:
    print("Testing CombatRoomResource with enemy generator...")

    # Create a combat room with enemy generator
    var combat_room := CombatRoomResource.new()

    # Create enemy template
    var template := EnemyTemplate.new()
    template.base_name = "Generated Goblin"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.FIRE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM

    # Create enemy generator
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    generator.modifier_chance = 0.0  # No modifiers for predictable testing

    combat_room.enemy_generator = generator

    # Create mock components for build_actions
    var actions_grid := GridContainer.new()
    var room_screen := RoomScreen.new()

    # This should work without errors
    combat_room.build_actions(actions_grid, room_screen)

    # Should have selected an enemy
    if not combat_room.selected_enemy:
        print("Expected selected_enemy to be set from generator")
        return false

    # Should have fire prefix from element affinity
    if combat_room.selected_enemy.name != "Fire Generated Goblin":
        print("Expected generated enemy name to be 'Fire Generated Goblin', got: ", combat_room.selected_enemy.name)
        return false

    # Should have stats calculated by generator
    if combat_room.selected_enemy.max_hp <= 0:
        print("Expected positive HP from generated enemy")
        return false

    if combat_room.selected_enemy.attack <= 0:
        print("Expected positive attack from generated enemy")
        return false

    actions_grid.queue_free()
    room_screen.queue_free()

    print("CombatRoomResource with enemy generator test passed")
    return true

func test_combat_room_generator_priority() -> bool:
    print("Testing CombatRoomResource generator priority over enemy list...")

    # Create a combat room with both generator and enemy list
    var combat_room := CombatRoomResource.new()

    # Add enemy list (should be ignored when generator is present)
    var list_enemy := EnemyResource.new()
    list_enemy.name = "List Enemy"
    combat_room.enemy_list = [list_enemy]

    # Create enemy template for generator
    var template := EnemyTemplate.new()
    template.base_name = "Generator Enemy"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM

    # Create enemy generator
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    generator.modifier_chance = 0.0

    combat_room.enemy_generator = generator

    # Create mock components
    var actions_grid := GridContainer.new()
    var room_screen := RoomScreen.new()

    # Build actions
    combat_room.build_actions(actions_grid, room_screen)

    # Should use generator, not enemy list
    if not combat_room.selected_enemy:
        print("Expected selected_enemy to be set")
        return false

    if combat_room.selected_enemy.name != "Generator Enemy":
        print("Expected generator to take priority over enemy list, got: ", combat_room.selected_enemy.name)
        return false

    actions_grid.queue_free()
    room_screen.queue_free()

    print("CombatRoomResource generator priority test passed")
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