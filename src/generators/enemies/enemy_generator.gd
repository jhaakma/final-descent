class_name EnemyGenerator extends Resource
## Generates enemies from templates using EnemyGenerationSettings and modifiers

@export var enemy_templates: Array[EnemyTemplate] = []
@export var modifier_chance: float = 0.2  ## Global modifier chance override

## Cache for generated enemies to avoid recreating identical enemies
var cache: Dictionary = {}

## Generate a random enemy from the configured templates
func generate_enemy(stage_number: int) -> EnemyResource:
    if enemy_templates.is_empty():
        push_error("EnemyGenerator: No enemy templates configured")
        return null

    # Select random template
    var template: EnemyTemplate = enemy_templates[GameState.rng.randi_range(0, enemy_templates.size() - 1)]

    # Generate enemy from template
    return generate_enemy_from_template(template, stage_number)

## Generate an enemy from a specific template
func generate_enemy_from_template(template: EnemyTemplate, stage_number: int) -> EnemyResource:
    # Get generation settings
    var settings := EnemyGenerationSettings.get_instance()

    # Get archetype base stats and apply level scaling
    var archetype_data := settings.get_archetype_data(template.archetype)
    var hp: int = _calculate_base_stat(archetype_data.base_hp, settings.hp_level_scaling, stage_number)
    var attack: int = _calculate_base_stat(archetype_data.base_attack, settings.attack_level_scaling, stage_number)
    var defense: int = archetype_data.base_defense + int(settings.defense_level_scaling * stage_number)
    var avoid_chance: float = archetype_data.base_avoid_chance

    # Apply size modifiers
    var size_data := settings.get_size_data(template.size_category)
    hp = int(round(hp * size_data.hp_modifier))
    attack = int(round(attack * size_data.attack_modifier))
    defense += size_data.defense_bonus
    avoid_chance = clamp(avoid_chance + size_data.avoid_modifier, 0.0, 1.0)

    # Create enemy resource
    var enemy := EnemyResource.new()
    enemy.name = template.base_name
    enemy.max_hp = hp
    enemy.attack = attack
    enemy.defense = defense
    enemy.avoid_chance = avoid_chance
    enemy.level = stage_number
    enemy.element_affinity = template.element_affinity
    enemy.physical_attack_type = template.physical_attack_type

    # Apply elemental resistances and weaknesses
    enemy.resistances = template.get_elemental_resistances()
    enemy.weaknesses = template.get_elemental_weaknesses()

    # Generate abilities
    enemy.abilities = _generate_abilities(template, enemy)

    # Apply modifiers if applicable (before caching so modifiers affect cache key)
    var effective_modifier_chance := template.modifier_chance if template.modifier_chance > 0 else modifier_chance
    if effective_modifier_chance > 0 and GameState.rng.randf() < effective_modifier_chance:
        _apply_random_modifier(enemy, template)

    # Check cache after all modifications
    var cache_key := _get_cache_key(enemy.name, enemy.max_hp, enemy.attack, enemy.defense)
    if cache.has(cache_key):
        return cache[cache_key]

    # Cache the generated enemy
    cache[cache_key] = enemy

    return enemy

## Calculate base stat with level scaling
func _calculate_base_stat(base_value: int, scaling_factor: float, level: int) -> int:
    # Formula: base * (1 + scaling_factor * (level - 1))
    var multiplier := 1.0 + (scaling_factor * (level - 1))
    return int(round(base_value * multiplier))


## Generate abilities from template
func _generate_abilities(template: EnemyTemplate, enemy: EnemyResource) -> Array[AbilityResource]:
    var abilities: Array[AbilityResource] = []

    # Use template's ability list if specified, otherwise add basic attack
    if not template.ability_templates.is_empty():
        # Generate abilities from templates
        for ability_template in template.ability_templates:
            if ability_template:
                var ability: AbilityResource = ability_template.generate_ability(enemy)
                if ability:
                    abilities.append(ability)
    else:
        # Fallback: always add basic attack if no templates specified
        var basic_attack_template := BasicAttackTemplate.new()
        var basic_attack: AbilityResource = basic_attack_template.generate_ability(enemy)
        if basic_attack:
            abilities.append(basic_attack)

    return abilities

## Apply a random modifier to the enemy
func _apply_random_modifier(enemy: EnemyResource, template: EnemyTemplate) -> void:
    # Use template's modifier pool if specified
    if template.modifier_pool.is_empty():
        return

    # Select random modifier from pool
    var modifier: EnemyModifier = EnemyModifierResolver.select_random_modifier(template.modifier_pool)

    if modifier:
        # Apply the modifier
        modifier.apply_to_enemy(enemy)

## Generate cache key for enemy
func _get_cache_key(name: String, hp: int, attack: int, defense: int) -> String:
    return "%s_%d_%d_%d" % [name, hp, attack, defense]
