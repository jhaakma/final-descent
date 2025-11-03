extends BaseTest
class_name EnemyGeneratorTest

## Test enemy generator functionality

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
    # No modifiers configured on template for basic test

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

func test_enemy_generator_with_element_affinity() -> bool:
    print("Testing enemy generation with element affinity...")

    # Create fire-aligned template
    var template := EnemyTemplate.new()
    template.base_name = "Salamander"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.FIRE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM

    # Create generator
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    # No modifiers configured on template

    # Generate enemy
    var enemy := generator.generate_enemy()

    if not enemy:
        print("Failed to generate fire enemy")
        return false

    if enemy.name != "Fire Salamander":
        print("Expected name 'Fire Salamander', got: ", enemy.name)
        return false

    if not enemy.resistances.has(DamageType.Type.FIRE):
        print("Expected fire resistance from element affinity")
        return false

    if not enemy.weaknesses.has(DamageType.Type.ICE):
        print("Expected ice weakness from element affinity")
        return false

    print("Element affinity generation test passed")
    return true

func test_enemy_generator_archetype_stats() -> bool:
    print("Testing enemy generation with different archetypes...")

    # Test BARBARIAN archetype (high attack, low HP)
    var barbarian_template := EnemyTemplate.new()
    barbarian_template.base_name = "Berserker"
    barbarian_template.archetype = EnemyTemplate.EnemyArchetype.BARBARIAN
    barbarian_template.base_level = 1
    barbarian_template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    barbarian_template.size_category = EnemyTemplate.SizeCategory.MEDIUM

    # Test TANK archetype (high HP, low attack)
    var tank_template := EnemyTemplate.new()
    tank_template.base_name = "Guardian"
    tank_template.archetype = EnemyTemplate.EnemyArchetype.TANK
    tank_template.base_level = 1
    tank_template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    tank_template.size_category = EnemyTemplate.SizeCategory.MEDIUM

    var generator := EnemyGenerator.new()
    generator.modifier_chance = 0.0

    # Generate barbarian
    generator.enemy_templates = [barbarian_template]
    var barbarian := generator.generate_enemy()

    # Generate tank
    generator.enemy_templates = [tank_template]
    var tank := generator.generate_enemy()

    if not barbarian or not tank:
        print("Failed to generate archetype enemies")
        return false

    # Barbarian should have higher attack than tank
    if barbarian.attack <= tank.attack:
        print("Expected barbarian attack (%d) to be higher than tank attack (%d)" % [barbarian.attack, tank.attack])
        return false

    # Tank should have higher HP than barbarian
    if tank.max_hp <= barbarian.max_hp:
        print("Expected tank HP (%d) to be higher than barbarian HP (%d)" % [tank.max_hp, barbarian.max_hp])
        return false

    print("Archetype stats test passed")
    return true

func test_enemy_generator_size_categories() -> bool:
    print("Testing enemy generation with different size categories...")

    # Create templates with different sizes
    var small_template := EnemyTemplate.new()
    small_template.base_name = "Rat"
    small_template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    small_template.base_level = 1
    small_template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    small_template.size_category = EnemyTemplate.SizeCategory.SMALL

    var huge_template := EnemyTemplate.new()
    huge_template.base_name = "Dragon"
    huge_template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    huge_template.base_level = 1
    huge_template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    huge_template.size_category = EnemyTemplate.SizeCategory.HUGE

    var generator := EnemyGenerator.new()
    generator.modifier_chance = 0.0

    # Generate small enemy
    generator.enemy_templates = [small_template]
    var small_enemy := generator.generate_enemy()

    # Generate huge enemy
    generator.enemy_templates = [huge_template]
    var huge_enemy := generator.generate_enemy()

    if not small_enemy or not huge_enemy:
        print("Failed to generate size variant enemies")
        return false

    # Huge enemy should have more HP than small enemy
    if huge_enemy.max_hp <= small_enemy.max_hp:
        print("Expected huge enemy HP (%d) to be higher than small enemy HP (%d)" % [huge_enemy.max_hp, small_enemy.max_hp])
        return false

    # Small enemy should have higher avoid chance than huge enemy
    if small_enemy.avoid_chance <= huge_enemy.avoid_chance:
        print("Expected small enemy avoid chance (%.2f) to be higher than huge enemy avoid chance (%.2f)" % [small_enemy.avoid_chance, huge_enemy.avoid_chance])
        return false

    print("Size categories test passed")
    return true

func test_enemy_generator_caching() -> bool:
    print("Testing enemy generation caching...")

    var template := EnemyTemplate.new()
    template.base_name = "Cached Goblin"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM

    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    generator.modifier_chance = 0.0

    # Generate same enemy twice
    var enemy1 := generator.generate_enemy()
    var enemy2 := generator.generate_enemy()

    if not enemy1 or not enemy2:
        print("Failed to generate enemies for caching test")
        return false

    # Should be the same instance due to caching
    if enemy1 != enemy2:
        print("Expected cached enemies to be the same instance")
        return false

    print("Enemy generation caching test passed")
    return true