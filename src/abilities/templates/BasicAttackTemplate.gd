class_name BasicAttackTemplate extends AbilityTemplate
## Template for generating basic attack abilities

func generate_ability(_user: EnemyResource = null) -> AbilityResource:
    var ability := AttackAbility.new()
    ability.ability_name = "Basic Attack"
    ability.description = "A basic attack"
    ability.priority = 10
    ability.base_damage = 0  # Will use user's attack stat
    ability.damage_variance = 2
    ability.log_action_player = "attack"
    ability.log_action_enemy = "attacks"
    ability.override_damage_type = false  # Use caster's physical attack type
    return ability
