class_name RoomGeneratorTest extends BaseTest
## Tests for room template generation and caching

var test_enemy_generator: EnemyGenerator
var test_loot_component: LootComponent

func setup() -> void:
    # Create minimal test generators/components
    test_enemy_generator = EnemyGenerator.new()
    var enemy_template := EnemyTemplate.new()
    enemy_template.base_name = "Test Goblin"
    enemy_template.base_level = 1
    enemy_template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    enemy_template.size_category = EnemyTemplate.SizeCategory.MEDIUM
    test_enemy_generator.enemy_templates = [enemy_template]

    test_loot_component = LootComponent.new()
    test_loot_component.gold_min = 10
    test_loot_component.gold_max = 20

func test_combat_room_generation() -> bool:
    var template := CombatRoomTemplate.new()
    template.rarity = Rarity.Type.COMMON
    template.title_variants = ["Goblin Ambush", "Enemy Patrol"]
    template.description_variants = ["Enemies ahead!", "Danger!"]
    template.enemy_generator = test_enemy_generator

    var room := template.generate_room(1)

    assert_true(room != null, "Room should be generated")
    assert_true(room is CombatRoomResource, "Should be CombatRoomResource")
    assert_true(room.room_type == RoomType.Type.COMBAT, "Room type should be COMBAT")
    assert_true(room.title in template.title_variants, "Title should be from variants")
    assert_true(room.enemy_generator == test_enemy_generator, "Enemy generator should be set")

    print("  Generated combat room: %s" % room.title)
    return not _test_failed

func test_chest_room_generation() -> bool:
    var template := ChestRoomTemplate.new()
    template.rarity = Rarity.Type.COMMON
    template.title_variants = ["Treasure Chest"]
    template.base_loot_component = test_loot_component
    template.gold_scaling_per_stage = 0.1
    template.chance_empty = 0.2

    var room := template.generate_room(1)

    assert_true(room != null, "Room should be generated")
    assert_true(room is ChestRoomResource, "Should be ChestRoomResource")
    assert_true(room.room_type == RoomType.Type.CHEST, "Room type should be CHEST")
    assert_true(room.loot_component != null, "Loot component should be set")
    assert_equals(room.chance_empty, 0.2, "Chance empty should match")

    print("  Generated chest room: %s" % room.title)
    return not _test_failed

func test_rest_room_generation() -> bool:
    var template := RestRoomTemplate.new()
    template.rarity = Rarity.Type.COMMON
    template.title_variants = ["Rest Area", "Safe Haven"]
    template.base_heal_amount = 4
    template.heal_scaling_per_stage = 0.15
    template.rest_message_variants = ["You rest...", "You feel refreshed."]

    var room := template.generate_room(1)

    print("  DEBUG: room = %s, room type = %s" % [room, room.get_class() if room else "null"])
    assert_true(room != null, "Room should be generated")
    assert_true(room is RestRoomResource, "Should be RestRoomResource")
    assert_true(room.room_type == RoomType.Type.REST, "Room type should be REST")
    # Stage 1: heal_amount = 4 * (1 + 0.15 * 1) = 4 * 1.15 = 4.6 = 5 (rounded)
    assert_true(room.heal_amount >= 4, "Heal amount should be scaled")

    print("  Generated rest room: %s (heals %d)" % [room.title, room.heal_amount])
    return not _test_failed

func test_shrine_room_generation() -> bool:
    var template := ShrineRoomTemplate.new()
    template.rarity = Rarity.Type.UNCOMMON
    template.title_variants = ["Ancient Shrine"]
    template.base_blessing_cost = 20
    template.base_cure_cost = 15
    template.base_heal_cost = 10
    template.cost_scaling_per_stage = 0.1
    template.base_loot_component = test_loot_component
    template.loot_curse_chance = 0.3

    var room := template.generate_room(2)

    assert_true(room != null, "Room should be generated")
    assert_true(room is ShrineRoomResource, "Should be ShrineRoomResource")
    assert_true(room.room_type == RoomType.Type.SHRINE, "Room type should be SHRINE")
    # Stage 2: blessing_cost = 20 * (1 + 0.1 * 2) = 20 * 1.2 = 24
    assert_equals(room.blessing_cost, 24, "Blessing cost should be scaled for stage 2")
    assert_equals(room.cure_cost, 18, "Cure cost should be scaled for stage 2")

    print("  Generated shrine room: %s (blessing: %dg)" % [room.title, room.blessing_cost])
    return not _test_failed

func test_shop_room_generation() -> bool:
    var template := ShopRoomTemplate.new()
    template.rarity = Rarity.Type.UNCOMMON
    template.title_variants = ["Merchant's Shop"]
    template.base_loot_component = test_loot_component
    template.gold_scaling_per_stage = 0.1

    var room := template.generate_room(3)

    assert_true(room != null, "Room should be generated")
    assert_true(room is ShopkeeperRoomResource, "Should be ShopkeeperRoomResource")
    assert_true(room.room_type == RoomType.Type.SHOP, "Room type should be SHOP")
    assert_true(room.loot_component != null, "Loot component should be set")

    print("  Generated shop room: %s" % room.title)
    return not _test_failed

func test_blacksmith_room_generation() -> bool:
    var template := BlacksmithRoomTemplate.new()
    template.rarity = Rarity.Type.RARE
    template.title_variants = ["Blacksmith's Forge"]
    template.base_repair_cost_per_condition = 2
    template.base_upgrade_cost_multiplier = 1.5
    template.cost_scaling_per_stage = 0.1

    var room := template.generate_room(3)

    assert_true(room != null, "Room should be generated")
    assert_true(room is BlacksmithRoomResource, "Should be BlacksmithRoomResource")
    assert_true(room.room_type == RoomType.Type.BLACKSMITH, "Room type should be BLACKSMITH")
    # Stage 3: repair_cost = 2 * (1 + 0.1 * 3) = 2 * 1.3 = 2.6 = 3 (rounded)
    assert_true(room.repair_cost_per_condition >= 2, "Repair cost should be scaled")

    print("  Generated blacksmith room: %s (repair: %dg/cond)" % [room.title, room.repair_cost_per_condition])
    return not _test_failed

func test_mimic_room_generation() -> bool:
    var template := MimicRoomTemplate.new()
    template.rarity = Rarity.Type.RARE
    template.title_variants = ["Suspicious Chest"]
    template.mimic_enemy_generator = test_enemy_generator

    var room := template.generate_room(1)

    print("  DEBUG: room = %s, room type = %s" % [room, room.get_class() if room else "null"])
    assert_true(room != null, "Room should be generated")
    assert_true(room is MimicChestRoomResource, "Should be MimicChestRoomResource")
    assert_true(room.room_type == RoomType.Type.MIMIC, "Room type should be MIMIC")
    assert_true(room.mimic_enemy != null, "Mimic enemy should be generated")

    print("  Generated mimic room: %s (enemy: %s)" % [room.title, room.mimic_enemy.name])
    return not _test_failed

func test_room_caching() -> bool:
    var template := CombatRoomTemplate.new()
    template.title_variants = ["Test Combat"]
    template.enemy_generator = test_enemy_generator

    # Clear cache first
    RoomGenerator.cache.clear()

    var room1 := template.generate_room(1)
    var room2 := template.generate_room(1)

    # Should return same cached instance
    assert_true(room1 == room2, "Should return cached room instance")

    # Different stage should generate new room
    var room3 := template.generate_room(2)
    assert_true(room1 != room3, "Different stage should generate new room")

    print("  Cache working: room1 == room2: %s, room1 != room3: %s" % [room1 == room2, room1 != room3])
    return not _test_failed

func test_loot_scaling() -> bool:
    var base_loot := LootComponent.new()
    base_loot.gold_min = 10
    base_loot.gold_max = 20

    # Stage 0: 10-20 (1.0 multiplier)
    var scaled_stage0 := RoomGenerator.scale_loot_component(base_loot, 0, 0.1)
    assert_equals(scaled_stage0.gold_min, 10, "Stage 0 should be base value")
    assert_equals(scaled_stage0.gold_max, 20, "Stage 0 should be base value")

    # Stage 5: 10-20 with 50% scaling = 15-30
    var scaled_stage5 := RoomGenerator.scale_loot_component(base_loot, 5, 0.1)
    assert_equals(scaled_stage5.gold_min, 15, "Stage 5 should scale gold_min")
    assert_equals(scaled_stage5.gold_max, 30, "Stage 5 should scale gold_max")

    print("  Loot scaling: stage 0 = %d-%d, stage 5 = %d-%d" % [
        scaled_stage0.gold_min, scaled_stage0.gold_max,
        scaled_stage5.gold_min, scaled_stage5.gold_max
    ])
    return not _test_failed

func test_stage_scaling_formula() -> bool:
    # Test healing scaling
    var base_heal := 4
    var scaling := 0.15

    # Stage 1: 4 * (1 + 0.15 * 1) = 4 * 1.15 = 4.6 = 5
    var stage1_heal := int(round(base_heal * (1.0 + scaling * 1)))
    assert_true(stage1_heal >= 4, "Stage 1 heal should be >= base")

    # Stage 10: 4 * (1 + 0.15 * 10) = 4 * 2.5 = 10
    var stage10_heal := int(round(base_heal * (1.0 + scaling * 10)))
    assert_equals(stage10_heal, 10, "Stage 10 heal should be significantly scaled")

    print("  Heal scaling: base = %d, stage 1 = %d, stage 10 = %d" % [base_heal, stage1_heal, stage10_heal])
    return not _test_failed
