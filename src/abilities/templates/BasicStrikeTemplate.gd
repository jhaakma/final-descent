class_name BasicStrikeTemplate extends AbilityTemplate
## Template for generating basic strike abilities

func generate_ability(user = null) -> AbilityResource:
    var effective_level := 1
    if user and user.has_method("get_level"):
        effective_level = user.get_level()

    var ability := AttackAbility.new()
    ability.ability_name = "Strike"
    ability.description = "A powerful strike"
    ability.priority = 8
    ability.base_damage = 2 + effective_level
    ability.damage_variance = 2
    ability.log_action_player = "strike"
    ability.log_action_enemy = "strikes"
    return ability
