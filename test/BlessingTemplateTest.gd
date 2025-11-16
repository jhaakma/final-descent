class_name BlessingTemplateTest extends BaseTest

class MockEntity extends CombatEntity:
    var level: int = 1

    func get_level() -> int:
        return level

func test_strength_blessing_scales_with_level() -> bool:
    var template := StrengthBlessingTemplate.new()
    template.base_attack_bonus = 3
    template.attack_bonus_per_level = 0.5
    template.base_duration = 10
    template.duration_per_level = 1.0

    # Mock entity with level 1
    var entity := MockEntity.new()
    entity.level = 1

    var condition_l1: StatusCondition = template.generate_condition(entity)
    var effect_l1 := condition_l1.status_effect as AttackBoostEffect

    assert_equals(effect_l1.attack_bonus, 3, "Level 1 should have 3 attack bonus")
    assert_equals(effect_l1.expire_after_turns, 11, "Level 1 should have 11 turns duration")

    # Mock entity with level 5
    entity.level = 5
    var condition_l5: StatusCondition = template.generate_condition(entity)
    var effect_l5 := condition_l5.status_effect as AttackBoostEffect

    assert_equals(effect_l5.attack_bonus, 5, "Level 5 should have 5 attack bonus (3 + 0.5*5 = 5.5 -> 5)")
    assert_equals(effect_l5.expire_after_turns, 15, "Level 5 should have 15 turns duration")

    # Mock entity with level 10
    entity.level = 10
    var condition_l10: StatusCondition = template.generate_condition(entity)
    var effect_l10 := condition_l10.status_effect as AttackBoostEffect

    assert_equals(effect_l10.attack_bonus, 8, "Level 10 should have 8 attack bonus (3 + 0.5*10 = 8)")
    assert_equals(effect_l10.expire_after_turns, 20, "Level 10 should have 20 turns duration")

    return not _test_failed

func test_defense_blessing_scales_with_level() -> bool:
    var template := DefenseBlessingTemplate.new()
    template.base_defense_bonus = 2
    template.defense_bonus_per_level = 0.4
    template.base_duration = 10
    template.duration_per_level = 1.0

    # Mock entity with level 1
    var entity := MockEntity.new()
    entity.level = 1

    var condition_l1: StatusCondition = template.generate_condition(entity)
    var effect_l1 := condition_l1.status_effect as DefenseBoostEffect

    assert_equals(effect_l1.defense_bonus, 2, "Level 1 should have 2 defense bonus")
    assert_equals(effect_l1.expire_after_turns, 11, "Level 1 should have 11 turns duration")

    # Mock entity with level 5
    entity.level = 5
    var condition_l5: StatusCondition = template.generate_condition(entity)
    var effect_l5 := condition_l5.status_effect as DefenseBoostEffect

    assert_equals(effect_l5.defense_bonus, 4, "Level 5 should have 4 defense bonus (2 + 0.4*5 = 4)")
    assert_equals(effect_l5.expire_after_turns, 15, "Level 5 should have 15 turns duration")

    return not _test_failed

func test_blessing_template_without_level() -> bool:
    var template := StrengthBlessingTemplate.new()
    template.base_attack_bonus = 3
    template.attack_bonus_per_level = 0.5

    # Generate without user object - should use level 1
    var condition: StatusCondition = template.generate_condition(null)
    var effect := condition.status_effect as AttackBoostEffect

    assert_equals(effect.attack_bonus, 3, "No user should default to level 1 (3 + 0.5*1 = 3.5 -> 3)")

    return not _test_failed

func test_shrine_room_uses_templates() -> bool:
    var template := ShrineRoomTemplate.new()
    template.base_blessing_cost = 20

    var strength_template := StrengthBlessingTemplate.new()
    strength_template.base_attack_bonus = 3
    strength_template.attack_bonus_per_level = 0.5

    var defense_template := DefenseBlessingTemplate.new()
    defense_template.base_defense_bonus = 2
    defense_template.defense_bonus_per_level = 0.4

    template.blessing_templates = [strength_template, defense_template]

    var room := template.generate_room(1) as ShrineRoomResource

    assert_true(room is ShrineRoomResource, "Should generate ShrineRoomResource")
    assert_equals(room.blessing_templates.size(), 2, "Should have 2 blessing templates")

    return not _test_failed
