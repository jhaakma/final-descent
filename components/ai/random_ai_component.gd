# components/random_ai_component.gd
class_name RandomAIComponent extends EnemyAIComponent

# Simple random AI implementation that selects abilities randomly
# This AI is suitable for basic enemies or testing purposes

# Main AI decision making method - selects a random usable ability
func plan_action(enemy, available_abilities: Array[Ability], _hp_percentage: float) -> Ability:
    if available_abilities.is_empty():
        return null

    # Filter abilities that can be used in current conditions
    var usable_abilities = filter_usable_abilities(enemy, available_abilities)

    if usable_abilities.is_empty():
        # If no abilities can be used, pick any available ability at random
        return available_abilities[randi() % available_abilities.size()]

    # Simply select a random ability considering use_chance and priority
    return select_random_ability_by_chance(usable_abilities)