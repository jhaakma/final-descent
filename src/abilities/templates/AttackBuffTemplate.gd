class_name AttackBuffTemplate extends AbilityTemplate
## Template for generating attack buff abilities based on user's level

func generate_ability(user: EnemyResource = null) -> AbilityResource:
    var effective_level := 1

    if user:
        effective_level = user.get_level()

    var ability := AttackBuffAbility.new()
    ability.ability_name = "Battle Rage"
    ability.description = "Enters a rage, temporarily boosting attack power"
    ability.priority = 12  # Medium-high priority
    ability.attack_bonus = 2 + effective_level  # Scales with level
    ability.duration = 1
    ability.log_action_player = "enter a rage"
    ability.log_action_enemy = "enters a rage"

    return ability
