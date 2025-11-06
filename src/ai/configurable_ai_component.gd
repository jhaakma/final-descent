# components/configurable_ai_component.gd
class_name ConfigurableAIComponent extends EnemyAIComponent

# Configurable AI implementation with @export properties for customization
# This AI allows designers to tune behavior without creating new AI classes

# Aggression level: 0.0 = defensive, 1.0 = very aggressive
@export_range(0.0, 1.0, 0.1) var aggression_level: float = 0.5

# Flee tendency: 0.0 = never flee, 1.0 = flee often when low health
@export_range(0.0, 1.0, 0.1) var flee_tendency: float = 0.2

# Defensive behavior: 0.0 = never defend, 1.0 = defend often
@export_range(0.0, 1.0, 0.1) var defensive_behavior: float = 0.3

# Preparation preference: 0.0 = avoid preparation, 1.0 = prefer preparation
@export_range(0.0, 1.0, 0.1) var preparation_preference: float = 0.4

# Buff usage: 0.0 = never use buffs, 1.0 = use buffs frequently
@export_range(0.0, 1.0, 0.1) var buff_usage: float = 0.3

# Health thresholds for different behaviors
@export_group("Health Thresholds")
@export_range(0.0, 1.0, 0.05) var critical_health_threshold: float = 0.25
@export_range(0.0, 1.0, 0.05) var low_health_threshold: float = 0.5

# Main AI decision making method with configurable behavior
func plan_action(enemy: CombatEntity, available_abilities: Array[AbilityInstance], hp_percentage: float) -> AbilityInstance:
    if available_abilities.is_empty():
        return null

    # Filter abilities that can be used in current conditions
    var usable_abilities := filter_usable_abilities(enemy, available_abilities)

    if usable_abilities.is_empty():
        # If no abilities can be used, pick any available ability at random
        return available_abilities[randi() % available_abilities.size()]

    # Categorize abilities for strategic selection
    var categorized_abilities := categorize_abilities_by_type(usable_abilities)

    # Select ability based on configurable parameters and current health
    return _select_configurable_ability(categorized_abilities, hp_percentage)

# Configurable ability selection based on export parameters
func _select_configurable_ability(categorized_abilities: CategorizedAbilities, hp_percentage: float) -> AbilityInstance:
    var selected_ability: AbilityInstance = null

    # Determine health state
    var is_critical_health := hp_percentage <= critical_health_threshold
    var is_low_health := hp_percentage <= low_health_threshold

    # Critical health behavior - prioritize survival
    if is_critical_health:
        # Try to flee if flee tendency is high enough
        if categorized_abilities.flee.size() > 0 and randf() < flee_tendency * 1.5:
            selected_ability = select_random_ability_by_priority(categorized_abilities.flee)
        # Defensive actions become more likely
        elif categorized_abilities.defend.size() > 0 and randf() < defensive_behavior * 1.2:
            selected_ability = select_random_ability_by_priority(categorized_abilities.defend)
        # Use buffs for survival
        elif categorized_abilities.buff.size() > 0 and randf() < buff_usage * 0.8:
            selected_ability = select_random_ability_by_priority(categorized_abilities.buff)

    # Low health behavior - balanced survival and offense
    elif is_low_health:
        # Moderate chance to flee
        if categorized_abilities.flee.size() > 0 and randf() < flee_tendency:
            selected_ability = select_random_ability_by_priority(categorized_abilities.flee)
        # Defensive behavior based on setting
        elif categorized_abilities.defend.size() > 0 and randf() < defensive_behavior:
            selected_ability = select_random_ability_by_priority(categorized_abilities.defend)
        # Buff usage for strategic advantage
        elif categorized_abilities.buff.size() > 0 and randf() < buff_usage:
            selected_ability = select_random_ability_by_priority(categorized_abilities.buff)

    # Healthy behavior - focus on configured preferences
    else:
        # High aggression means more preparation and direct attacks
        if aggression_level > 0.7:
            # Prefer preparation for powerful attacks
            if categorized_abilities.preparation.size() > 0 and randf() < preparation_preference * 1.3:
                selected_ability = select_random_ability_by_priority(categorized_abilities.preparation)
        # Medium aggression allows for buffs and preparation
        elif aggression_level > 0.3:
            # Balanced use of buffs and preparation
            if categorized_abilities.buff.size() > 0 and randf() < buff_usage:
                selected_ability = select_random_ability_by_priority(categorized_abilities.buff)
            elif categorized_abilities.preparation.size() > 0 and randf() < preparation_preference:
                selected_ability = select_random_ability_by_priority(categorized_abilities.preparation)
        # Low aggression prefers defensive and support actions
        else:
            # More defensive behavior
            if categorized_abilities.defend.size() > 0 and randf() < defensive_behavior * 1.2:
                selected_ability = select_random_ability_by_priority(categorized_abilities.defend)
            elif categorized_abilities.buff.size() > 0 and randf() < buff_usage * 1.1:
                selected_ability = select_random_ability_by_priority(categorized_abilities.buff)

    # Fallback strategy: Default to attacks based on aggression, then any available ability
    if selected_ability == null:
        if categorized_abilities.attack.size() > 0:
            # Aggression affects attack selection probability
            if randf() < 0.5 + (aggression_level * 0.4):  # Range: 0.5 to 0.9
                selected_ability = select_random_ability_by_priority(categorized_abilities.attack)

        # Final fallback: pick any available ability randomly
        if selected_ability == null:
            var all_abilities := categorized_abilities.get_all_abilities()
            if all_abilities.size() > 0:
                selected_ability = all_abilities[randi() % all_abilities.size()]

    return selected_ability