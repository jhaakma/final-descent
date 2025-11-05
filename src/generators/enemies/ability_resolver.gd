class_name AbilityResolver extends RefCounted
## Resolves ability templates into actual AbilityResource instances

## Generate an ability from a template
static func generate_ability(
    template: EnemyTemplate.AbilityTemplate,
    element_affinity: EnemyTemplate.ElementAffinity,
    size_category: EnemyTemplate.SizeCategory,
    level: int,
    _archetype: EnemyTemplate.EnemyArchetype
) -> AbilityResource:
    match template:
        EnemyTemplate.AbilityTemplate.BASIC_ATTACK:
            return _create_basic_attack()
        EnemyTemplate.AbilityTemplate.BASIC_STRIKE:
            return _create_basic_strike(level)
        EnemyTemplate.AbilityTemplate.ELEMENTAL_STRIKE:
            return _create_elemental_strike(element_affinity, level)
        EnemyTemplate.AbilityTemplate.BREATH_ATTACK:
            return _create_breath_attack(element_affinity, size_category, level)
        EnemyTemplate.AbilityTemplate.POISON_ATTACK:
            return _create_poison_attack(level)
        EnemyTemplate.AbilityTemplate.DEFEND:
            return _create_defend_ability()
        EnemyTemplate.AbilityTemplate.HEAL:
            return _create_heal_ability(level)
        EnemyTemplate.AbilityTemplate.BUFF_ATTACK:
            return _create_buff_attack(level)
        EnemyTemplate.AbilityTemplate.BUFF_DEFENSE:
            return _create_buff_defense(level)
        _:
            push_error("Unknown ability template: %s" % template)
            return null

## Create basic attack ability
static func _create_basic_attack() -> AbilityResource:
    var ability := AttackAbility.new()
    ability.ability_name = "Basic Attack"
    ability.description = "A basic attack"
    ability.priority = 10
    ability.base_damage = 0  # Will use enemy's attack stat
    ability.damage_variance = 2
    return ability

## Create basic strike ability
static func _create_basic_strike(level: int) -> AbilityResource:
    var ability := AttackAbility.new()
    ability.ability_name = "Strike"
    ability.description = "A powerful strike"
    ability.priority = 8
    ability.base_damage = 2 + level
    ability.damage_variance = 2
    return ability

## Create elemental strike ability
static func _create_elemental_strike(element_affinity: EnemyTemplate.ElementAffinity, level: int) -> AbilityResource:
    var ability := AttackAbility.new()
    var element_name := _get_element_name(element_affinity)
    ability.ability_name = "%s Strike" % element_name
    ability.description = "A strike infused with %s energy" % element_name.to_lower()
    ability.priority = 7
    ability.base_damage = 3 + level
    ability.damage_variance = 2
    ability.damage_type = _get_damage_type(element_affinity)
    return ability

## Create breath attack ability (requires LARGE or HUGE size)
static func _create_breath_attack(
    element_affinity: EnemyTemplate.ElementAffinity,
    size_category: EnemyTemplate.SizeCategory,
    level: int
) -> AbilityResource:
    # Check size requirement
    if size_category != EnemyTemplate.SizeCategory.LARGE and size_category != EnemyTemplate.SizeCategory.HUGE:
        push_error("Breath attack requires LARGE or HUGE size category")
        return null

    var ability := AttackAbility.new()
    var element_name := _get_element_name(element_affinity)
    ability.ability_name = "%s Breath" % element_name
    ability.description = "Exhales a blast of %s energy" % element_name.to_lower()
    ability.priority = 6
    ability.base_damage = 5 + (level * 2)
    ability.damage_variance = 3
    ability.damage_type = _get_damage_type(element_affinity)
    return ability

## Create poison attack ability
static func _create_poison_attack(level: int) -> AbilityResource:
    var ability := AttackAbility.new()
    ability.ability_name = "Poison Strike"
    ability.description = "A venomous attack that poisons the target"
    ability.priority = 7
    ability.base_damage = 2 + level
    ability.damage_variance = 2
    ability.damage_type = DamageType.Type.POISON
    return ability

## Create defend ability
static func _create_defend_ability() -> AbilityResource:
    var ability := DefendAbility.new()
    ability.ability_name = "Defend"
    ability.description = "Take a defensive stance"
    ability.priority = 5
    return ability

## Create heal ability
static func _create_heal_ability(_level: int) -> AbilityResource:
    # For now, return null - healing abilities need specific implementation
    # TODO: Implement healing ability when HealAbility class is available
    push_error("Heal ability not yet implemented")
    return null

## Create buff attack ability
static func _create_buff_attack(_level: int) -> AbilityResource:
    # For now, return null - buff abilities need specific implementation
    # TODO: Implement buff ability when BuffAbility class is available
    push_error("Buff attack ability not yet implemented")
    return null

## Create buff defense ability
static func _create_buff_defense(_level: int) -> AbilityResource:
    # For now, return null - buff abilities need specific implementation
    # TODO: Implement buff ability when BuffAbility class is available
    push_error("Buff defense ability not yet implemented")
    return null

## Helper: Get element name for display
static func _get_element_name(element_affinity: EnemyTemplate.ElementAffinity) -> String:
    match element_affinity:
        EnemyTemplate.ElementAffinity.FIRE:
            return "Fire"
        EnemyTemplate.ElementAffinity.ICE:
            return "Ice"
        EnemyTemplate.ElementAffinity.SHOCK:
            return "Shock"
        EnemyTemplate.ElementAffinity.POISON, EnemyTemplate.ElementAffinity.TOXIC:
            return "Poison"
        EnemyTemplate.ElementAffinity.HOLY:
            return "Holy"
        EnemyTemplate.ElementAffinity.DARK:
            return "Dark"
        _:
            return "Elemental"

## Helper: Get damage type from element affinity
static func _get_damage_type(element_affinity: EnemyTemplate.ElementAffinity) -> DamageType.Type:
    match element_affinity:
        EnemyTemplate.ElementAffinity.FIRE:
            return DamageType.Type.FIRE
        EnemyTemplate.ElementAffinity.ICE:
            return DamageType.Type.ICE
        EnemyTemplate.ElementAffinity.SHOCK:
            return DamageType.Type.SHOCK
        EnemyTemplate.ElementAffinity.POISON, EnemyTemplate.ElementAffinity.TOXIC:
            return DamageType.Type.POISON
        EnemyTemplate.ElementAffinity.HOLY:
            return DamageType.Type.HOLY
        EnemyTemplate.ElementAffinity.DARK:
            return DamageType.Type.DARK
        _:
            return DamageType.Type.BLUNT
