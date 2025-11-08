extends BaseTest

var chest_room: RoomResource
var combat_room1: RoomResource
var combat_room2: RoomResource
var rest_room: RoomResource
var boss_room: RoomResource
var template: StageTemplateResource

func setup() -> void:
    # Create lightweight room instances with tags
    chest_room = RoomResource.new()
    chest_room.title = "Test Chest"
    chest_room.tags = [StageTags.Tag.CHEST]
    chest_room.rarity = 1.0

    combat_room1 = RoomResource.new()
    combat_room1.title = "Test Combat 1"
    combat_room1.tags = [StageTags.Tag.COMBAT]
    combat_room1.rarity = 1.0

    combat_room2 = RoomResource.new()
    combat_room2.title = "Test Combat 2"
    combat_room2.tags = [StageTags.Tag.COMBAT]
    combat_room2.rarity = 1.0

    rest_room = RoomResource.new()
    rest_room.title = "Test Rest"
    rest_room.tags = [StageTags.Tag.REST]
    rest_room.rarity = 1.0

    boss_room = RoomResource.new()
    boss_room.title = "Test Boss"
    boss_room.tags = [StageTags.Tag.BOSS]
    boss_room.rarity = 1.0

    # Create a simple template
    template = StageTemplateResource.new()
    template.floors = 5
    template.mandatory_room_tags = [StageTags.Tag.CHEST, StageTags.Tag.REST]
    template.optional_tag_weights = {
        StageTags.Tag.COMBAT: 2.0,
        StageTags.Tag.REST: 0.5
    }
    template.boss_selector = func() -> RoomResource: return boss_room

func test_stage_manager_integration() -> bool:
    var rooms: Array[RoomResource] = [chest_room, combat_room1, combat_room2, rest_room, boss_room]
    var history: Array[RoomResource] = []

    # Generate a stage instance
    var instance := StageGenerator.generate(1, template, 42, rooms, history)

    assert_true(instance != null, "Instance should be created")
    assert_true(instance.integrity_ok, "Instance should have integrity")
    assert_equals(instance.planned_rooms.size(), 5, "Should have 5 planned rooms")

    # Set the instance in StageManager
    StageManager.set_stage_instance(instance)

    # Verify StageManager reports having a plan
    assert_true(StageManager.has_stage_plan(), "StageManager should have a plan")

    # Get first planned room
    var first_room := StageManager.get_current_planned_room()
    assert_true(first_room != null, "First room should not be null")
    assert_true(first_room in instance.planned_rooms, "First room should be in planned rooms")

    print("  First planned room: %s" % first_room.title)

    return true

func test_stage_manager_advance() -> bool:
    var rooms: Array[RoomResource] = [chest_room, combat_room1, combat_room2, rest_room, boss_room]
    var history: Array[RoomResource] = []

    var instance := StageGenerator.generate(1, template, 42, rooms, history)
    StageManager.set_stage_instance(instance)

    # Get first room
    var room1 := StageManager.get_current_planned_room()

    # Use StageManager to advance (which increments floors_completed_in_current_stage)
    StageManager.advance_floor()

    # Get second room
    var room2 := StageManager.get_current_planned_room()

    assert_true(room1 != room2 or instance.planned_rooms.size() == 1, "Should advance to different room or be single room")

    print("  Room 1: %s" % room1.title)
    print("  Room 2: %s" % room2.title)

    return true

func test_stage_manager_finish() -> bool:
    var rooms: Array[RoomResource] = [chest_room, combat_room1, combat_room2, rest_room, boss_room]
    var history: Array[RoomResource] = []

    var instance := StageGenerator.generate(1, template, 42, rooms, history)
    StageManager.set_stage_instance(instance)

    # Advance through all rooms using StageManager
    var iterations := 0
    while StageManager.get_floors_remaining_in_stage() > 0 and iterations < 20:
        StageManager.advance_floor()
        iterations += 1

    # Check we completed the expected number of floors (minus 1 since we start at floor 0)
    assert_true(iterations == template.floors - 1, "Should advance floors-1 times")

    # Should be on boss floor now
    assert_true(StageManager.is_boss_floor(), "Should be on boss floor")

    var boss := StageManager.get_current_planned_room()
    assert_true(boss != null, "Boss room should not be null")
    assert_true(boss.has_tag(StageTags.Tag.BOSS), "Boss room should have BOSS tag")

    print("  Iterations: %d" % iterations)
    print("  Boss room: %s" % boss.title)

    return true
