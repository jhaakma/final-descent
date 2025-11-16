class_name StageGeneratorTest extends BaseTest

var chest_room: RoomResource
var combat_room: RoomResource
var rest_room: RoomResource
var boss_room: RoomResource

func setup() -> void:
    # Construct lightweight in-memory room resources
    chest_room = RoomResource.new()
    chest_room.title = "Chest"
    chest_room.room_type = RoomType.Type.CHEST
    chest_room.rarity = Rarity.Type.COMMON

    combat_room = RoomResource.new()
    combat_room.title = "Combat"
    combat_room.room_type = RoomType.Type.COMBAT
    combat_room.rarity = Rarity.Type.COMMON

    rest_room = RoomResource.new()
    rest_room.title = "Rest"
    rest_room.room_type = RoomType.Type.REST
    rest_room.rarity = Rarity.Type.COMMON

    boss_room = RoomResource.new()
    boss_room.title = "Boss"
    boss_room.room_type = RoomType.Type.BOSS
    boss_room.rarity = Rarity.Type.COMMON

func _build_template(mandatory: Array[RoomType.Type], floors: int, pre_boss: RoomType.Type = RoomType.Type.NONE) -> StageTemplateResource:
    var template := StageTemplateResource.new()
    template.floors = floors
    template.mandatory_room_types = mandatory
    template.pre_boss_room_type = pre_boss
    template.boss_selector = func() -> RoomResource: return boss_room
    template.optional_type_weights = {
        RoomType.Type.CHEST: 1.0,
        RoomType.Type.COMBAT: 2.0,
        RoomType.Type.REST: 1.0
    }
    template.max_repeats_per_type = {
        RoomType.Type.COMBAT: 10,
        RoomType.Type.CHEST: 5,
        RoomType.Type.REST: 3
    }
    return template

func test_mandatory_chest_present() -> bool:
    var template := _build_template([RoomType.Type.CHEST], 5)
    var rooms: Array[RoomResource] = [chest_room, combat_room, rest_room, boss_room]
    var history: Array[RoomResource] = []
    var instance := StageGenerator.generate(1, template, 12345, rooms, history)
    var found_chest := false
    for r in instance.planned_rooms:
        if r.room_type == RoomType.Type.CHEST:
            found_chest = true
            break
    assert_true(found_chest, "Mandatory CHEST type not found in planned rooms")
    assert_true(instance.planned_rooms.back() == boss_room, "Boss room not last")
    return not _test_failed

func test_boss_last_position() -> bool:
    var template := _build_template([], 3)
    var rooms: Array[RoomResource] = [combat_room, rest_room, boss_room]
    var history: Array[RoomResource] = []
    var instance := StageGenerator.generate(1, template, 888, rooms, history)
    assert_equals(instance.planned_rooms.size(), 3, "Expected 3 rooms including boss")
    assert_true(instance.planned_rooms.back().room_type == RoomType.Type.BOSS, "Boss type not in last room")
    return not _test_failed

func test_pre_boss_reservation() -> bool:
    var template := _build_template([RoomType.Type.CHEST], 6, RoomType.Type.REST)
    var rooms: Array[RoomResource] = [chest_room, combat_room, rest_room, boss_room]
    var history: Array[RoomResource] = []
    var instance := StageGenerator.generate(1, template, 777, rooms, history)
    # Pre-boss slot is floors-2 index (since last is boss)
    var pre_boss_index := template.floors - 2
    var pre_boss_room_result := instance.planned_rooms[pre_boss_index]
    assert_true(pre_boss_room_result.room_type == RoomType.Type.REST, "Pre-boss REST room not reserved correctly")
    return not _test_failed

func test_determinism_same_seed() -> bool:
    var template := _build_template([RoomType.Type.COMBAT], 5)
    var rooms: Array[RoomResource] = [combat_room, chest_room, rest_room, boss_room]
    var history: Array[RoomResource] = []
    var gen_seed := 424242
    var instance_a := StageGenerator.generate(2, template, gen_seed, rooms, history)
    var instance_b := StageGenerator.generate(2, template, gen_seed, rooms, history)
    assert_equals(instance_a.planned_rooms.size(), instance_b.planned_rooms.size(), "Size mismatch for deterministic generation")
    var identical := true
    for i in range(instance_a.planned_rooms.size()):
        if instance_a.planned_rooms[i].title != instance_b.planned_rooms[i].title:
            identical = false
            break
    assert_true(identical, "Plans differ for same seed")
    return not _test_failed

func test_fallback_when_missing_mandatory() -> bool:
    # Mandatory EVENT not available (no room has EVENT type) -> should fallback and set integrity false
    var template := _build_template([RoomType.Type.EVENT], 4)
    var rooms: Array[RoomResource] = [combat_room, chest_room, rest_room, boss_room]
    var history: Array[RoomResource] = []
    var instance := StageGenerator.generate(1, template, 999, rooms, history)
    assert_false(instance.integrity_ok, "Integrity should be false after fallback mandatory failure")
    # Ensure boss still last
    assert_true(instance.planned_rooms.back() == boss_room, "Boss room not last after fallback")
    return not _test_failed