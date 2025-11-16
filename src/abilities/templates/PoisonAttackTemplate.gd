class_name PoisonAttackTemplate extends AbilityTemplate
## Template for generating poison attack abilities

func generate_ability(user: EnemyResource) -> AbilityResource:
    var effective_level := 1
    if user:
        effective_level = user.get_level()

    var ability := AttackAbility.new()
    ability.ability_name = "Poison Strike"
    ability.description = "A venomous attack that poisons the target"
    ability.priority = 7
    ability.base_damage = 2 + effective_level
    ability.damage_variance = 2
    ability.damage_type = DamageType.Type.POISON
    ability.status_effect = ElementalTimedEffect.new(1, DamageType.Type.POISON, 4)
    return ability
