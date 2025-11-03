class_name AbilityGenerationTest extends BaseTest

func get_test_category() -> String:
    return "AbilityGeneration"

## Test that basic ability generation works correctly
func test_ability_generation_basic() -> bool:
    # Create a simple template with no ability templates (just basic attack)
    var template := EnemyTemplate.new()
    template.base_name = "Test Goblin"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.NONE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM
    template.ability_templates = []

    # Create generator and generate enemy
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    var enemy := generator.generate_enemy()

    if not assert_not_null(enemy, "Enemy should be generated"):
        return false

    if not assert_true(enemy.abilities.size() >= 1, "Enemy should have at least one ability (basic attack)"):
        return false

    var basic_attack := enemy.abilities[0]
    if not assert_not_null(basic_attack, "Basic attack should exist"):
        return false

    if not assert_equals(basic_attack.ability_name, "Basic Attack", "First ability should be basic attack"):
        return false

    return true

## Test ability generation with additional templates
func test_ability_generation_with_templates() -> bool:
    # Create template with additional abilities
    var template := EnemyTemplate.new()
    template.base_name = "Fire Warrior"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 2
    template.element_affinity = EnemyTemplate.ElementAffinity.FIRE
    template.size_category = EnemyTemplate.SizeCategory.MEDIUM
    template.ability_templates = [
        EnemyTemplate.AbilityTemplate.BASIC_STRIKE,
        EnemyTemplate.AbilityTemplate.ELEMENTAL_STRIKE
    ]

    # Create generator and generate enemy
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    var enemy := generator.generate_enemy()

    if not assert_not_null(enemy, "Enemy should be generated"):
        return false

    # Should have basic attack + 2 additional abilities
    if not assert_true(enemy.abilities.size() >= 3, "Enemy should have at least 3 abilities (basic + 2 templates)"):
        print("Expected at least 3 abilities, got: %d" % enemy.abilities.size())
        for i in enemy.abilities.size():
            print("  Ability %d: %s" % [i, enemy.abilities[i].ability_name])
        return false

    # Verify basic attack is still present
    var has_basic_attack := false
    for ability: AbilityResource in enemy.abilities:
        if ability.ability_name == "Basic Attack":
            has_basic_attack = true
            break

    if not assert_true(has_basic_attack, "Should still have basic attack"):
        return false

    return true

## Test ability generation with breath attack (size requirement)
func test_ability_generation_breath_attack() -> bool:
    # Create large fire creature with breath attack
    var template := EnemyTemplate.new()
    template.base_name = "Fire Dragon"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 5
    template.element_affinity = EnemyTemplate.ElementAffinity.FIRE
    template.size_category = EnemyTemplate.SizeCategory.LARGE
    template.ability_templates = [
        EnemyTemplate.AbilityTemplate.BREATH_ATTACK
    ]

    # Create generator and generate enemy
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    var enemy := generator.generate_enemy()

    if not assert_not_null(enemy, "Enemy should be generated"):
        return false

    # Should have basic attack + breath attack
    if not assert_true(enemy.abilities.size() >= 2, "Enemy should have at least 2 abilities"):
        print("Expected at least 2 abilities, got: %d" % enemy.abilities.size())
        return false

    # Look for breath ability
    var has_breath := false
    for ability: AbilityResource in enemy.abilities:
        if "Breath" in ability.ability_name:
            has_breath = true
            break

    if not assert_true(has_breath, "Should have breath attack ability"):
        print("Abilities found:")
        for ability in enemy.abilities:
            print("  - %s" % ability.ability_name)
        return false

    return true

## Test that incompatible templates are rejected gracefully
func test_ability_generation_incompatible_template() -> bool:
    # Create small creature trying to use breath attack (should fail size requirement)
    var template := EnemyTemplate.new()
    template.base_name = "Small Fire Sprite"
    template.archetype = EnemyTemplate.EnemyArchetype.WARRIOR
    template.base_level = 1
    template.element_affinity = EnemyTemplate.ElementAffinity.FIRE
    template.size_category = EnemyTemplate.SizeCategory.SMALL
    template.ability_templates = [
        EnemyTemplate.AbilityTemplate.BREATH_ATTACK  # Should fail for small creatures
    ]

    # Create generator and generate enemy
    var generator := EnemyGenerator.new()
    generator.enemy_templates = [template]
    var enemy := generator.generate_enemy()

    if not assert_not_null(enemy, "Enemy should still be generated"):
        return false

    # Should only have basic attack (breath attack should fail)
    if not assert_equals(enemy.abilities.size(), 1, "Should only have basic attack (breath attack rejected)"):
        print("Expected 1 ability, got: %d" % enemy.abilities.size())
        return false

    if not assert_equals(enemy.abilities[0].ability_name, "Basic Attack", "Only ability should be basic attack"):
        return false

    return true