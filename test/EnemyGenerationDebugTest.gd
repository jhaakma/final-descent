class_name EnemyGenerationDebugTest extends BaseTest

func get_test_category() -> String:
    return "EnemyGenerationDebug"

func test_goblin_template_ability_generation() -> bool:
    # Load the goblin template
    var template: EnemyTemplate = load("res://data/generated/enemies/templates/lvl1_goblin.tres") as EnemyTemplate
    if not template:
        print("Failed to load goblin template")
        return false

    print("Template loaded:")
    print("  Name: %s" % template.base_name)
    print("  Archetype: %s" % template.archetype)
    print("  Element: %s" % template.element_affinity)
    print("  Size: %s" % template.size_category)
    print("  Ability templates: %s" % template.ability_templates)

    # Test ability generation directly
    if not template.ability_templates.is_empty():
        var first_template: EnemyTemplate.AbilityTemplate = template.ability_templates[0]
        print("Testing ability template: %s" % first_template)

        var generated_ability: AbilityResource = AbilityResolver.generate_ability(
            first_template,
            template.element_affinity,
            template.size_category,
            template.base_level,
            template.archetype
        )

        if generated_ability:
            print("Successfully generated ability: %s" % generated_ability.ability_name)
        else:
            print("Failed to generate ability from template!")
            return false

    # Test full enemy generation
    print("\nTesting full enemy generation:")
    var generator: EnemyGenerator = EnemyGenerator.new()
    generator.enemy_templates = [template]
    var enemy: EnemyResource = generator.generate_enemy()

    if enemy:
        print("Enemy generated: %s" % enemy.name)
        print("Abilities (%d):" % enemy.abilities.size())
        for i: int in enemy.abilities.size():
            var ability: AbilityResource = enemy.abilities[i]
            print("  %d: %s" % [i, ability.ability_name])

        # Check if we have the expected ability
        if enemy.abilities.size() == 1 and enemy.abilities[0].ability_name == "Basic Attack":
            print("ERROR: Enemy only has Basic Attack, template ability generation failed!")
            return false

        return true
    else:
        print("Failed to generate enemy!")
        return false