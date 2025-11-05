extends BaseTest
class_name EnemyGeneratorIntegrationTest

## Test that enemy generation integrates with combat rooms

func test_enemy_generator_basic_creation() -> bool:
    print("Testing basic enemy generation...")

    # Create a simple template
    var template := EnemyTemplate.new()
    template.base_name = "Test Goblin"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM

    # Create generator
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    generator.modifier_chance = 0.0  # No modifiers for basic test

    # Generate enemy
    var enemy := generator.generate_enemy()

    if not enemy:
        print("Failed to generate enemy")
        return false

    if enemy.name != "Test Goblin":
        print("Expected name 'Test Goblin', got: ", enemy.name)
        return false

    if enemy.max_hp <= 0:
        print("Expected positive HP, got: ", enemy.max_hp)
        return false

    if enemy.attack <= 0:
        print("Expected positive attack, got: ", enemy.attack)
        return false

    if enemy.abilities.is_empty():
        print("Expected at least one ability")
        return false

    print("Basic enemy generation test passed")
    return true

func test_combat_room_with_generator() -> bool:
    print("Testing CombatRoomResource with enemy generator...")

    # Create a template
    var template := EnemyTemplate.new()
    template.base_name = "Generated Goblin"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 2
    template.element_affinity = EnemyTemplate.ElementAffinity.FIRE
    template.size_category = EnemyTemplate.SizeCategory.SMALL

    # Create generator
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    generator.modifier_chance = 0.0

    # Create combat room with generator
    var combat_room := CombatRoomResource.new()
    combat_room.enemy_generator = generator

    # Create mock components
    var actions_grid := GridContainer.new()
    var room_screen := RoomScreen.new()

    # Build actions should generate an enemy
    combat_room.build_actions(actions_grid, room_screen)

    # Should have selected an enemy
    if not combat_room.selected_enemy:
        print("Expected selected_enemy to be set")
        return false

    # Should be a fire goblin
    if combat_room.selected_enemy.name != "Fire Generated Goblin":
        print("Expected 'Fire Generated Goblin', got: ", combat_room.selected_enemy.name)
        return false

    # Should have fire resistance
    if not combat_room.selected_enemy.resistances.has(DamageType.Type.FIRE):
        print("Expected fire resistance")
        return false

    actions_grid.queue_free()
    room_screen.queue_free()

    print("Combat room with generator test passed")
    return true

func test_enemy_generation_with_modifier() -> bool:
    print("Testing enemy generation with modifier...")

    # Create template
    var template := EnemyTemplate.new()
    template.base_name = "Slime"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM
    template.possible_modifiers = [EnemyModifierResolver.ModifierType.ELITE]
    template.modifier_chance = 1.0  # Always apply

    # Create generator
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]

    # Generate enemy
    var enemy := generator.generate_enemy()

    if not enemy:
        print("Failed to generate enemy")
        return false

    # Should have Elite prefix
    if not enemy.name.begins_with("Elite"):
        print("Expected 'Elite' prefix, got name: ", enemy.name)
        return false

    # Create baseline for comparison
    template.modifier_chance = 0.0
    var baseline := generator.generate_enemy()

    # Elite should have higher stats
    if enemy.max_hp <= baseline.max_hp:
        print("Expected elite HP (%d) > baseline HP (%d)" % [enemy.max_hp, baseline.max_hp])
        return false

    print("Enemy generation with modifier test passed")
    return true

func test_ability_generation_from_templates() -> bool:
    print("Testing ability generation from templates...")

    # Create template with specific abilities
    var template := EnemyTemplate.new()
    template.base_name = "Test Warrior"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.FIRE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM
    template.ability_templates = [
        EnemyTemplate.AbilityTemplate.BASIC_ATTACK,
        EnemyTemplate.AbilityTemplate.DEFEND,
        EnemyTemplate.AbilityTemplate.ELEMENTAL_STRIKE
    ]

    # Create generator
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    generator.modifier_chance = 0.0

    # Generate enemy
    var enemy := generator.generate_enemy()

    if not assert_not_null(enemy, "Failed to generate enemy"):
        return false

    # Should have exactly 3 abilities
    if not assert_equals(enemy.abilities.size(), 3, "Expected 3 abilities"):
        return false

    # Check for basic attack ability
    var has_basic_attack := false
    var has_defend := false
    var has_elemental := false

    for ability in enemy.abilities:
        if ability.ability_name == "Basic Attack":
            has_basic_attack = true
        elif ability.ability_name == "Defend":
            has_defend = true
        elif ability.ability_name == "Fire Strike":
            has_elemental = true

    if not assert_true(has_basic_attack, "Missing basic attack ability"):
        return false

    if not assert_true(has_defend, "Missing defend ability"):
        return false

    if not assert_true(has_elemental, "Missing elemental strike ability (expected 'Fire Strike')"):
        return false

    print("Ability generation from templates test passed")
    return true
