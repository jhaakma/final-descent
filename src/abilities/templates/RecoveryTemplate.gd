class_name RecoveryTemplate extends AbilityTemplate
## Template for generating recovery abilities based on user's level

func generate_ability(user: EnemyResource = null) -> AbilityResource:
    var effective_level := 1

    if user:
        effective_level = user.get_level()

    var ability := RecoveryAbility.new()
    ability.ability_name = "Regenerate"
    ability.description = "Restores health gradually over several turns"
    ability.priority = 10  # Medium priority
    ability.healing_per_turn = 1 + (effective_level / 2)  # Scales with level
    ability.duration = 3
    ability.log_action_player = "focus on regenerating"
    ability.log_action_enemy = "focuses on regenerating"
    ability.cooldown = 5
    return ability
