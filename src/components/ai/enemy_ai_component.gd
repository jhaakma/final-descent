# components/enemy_ai_component.gd
class_name EnemyAIComponent extends Resource

# Abstract base class for enemy AI decision making components
# This class defines the interface that all AI implementations must follow

# Type-safe container for categorized abilities
class CategorizedAbilities:
    var attack: Array[Ability] = []
    var defend: Array[Ability] = []
    var buff: Array[Ability] = []
    var preparation: Array[Ability] = []
    var flee: Array[Ability] = []
    var other: Array[Ability] = []

    # Helper method to get all abilities as a flat array
    func get_all_abilities() -> Array[Ability]:
        var all_abilities: Array[Ability] = []
        all_abilities.append_array(attack)
        all_abilities.append_array(defend)
        all_abilities.append_array(buff)
        all_abilities.append_array(preparation)
        all_abilities.append_array(flee)
        all_abilities.append_array(other)
        return all_abilities

# Plan an action for the enemy based on current game state
# This method should analyze the enemy's situation and select an appropriate ability
# Parameters:
# - enemy: The enemy that needs to plan an action
# - available_abilities: Array of abilities the enemy can potentially use
# - hp_percentage: The enemy's current health as a percentage (0.0 - 1.0)
# Returns: The selected Ability to execute, or null if no ability should be used
func plan_action(_enemy: CombatEntity, _available_abilities: Array[Ability], _hp_percentage: float) -> Ability:
    push_error("EnemyAIComponent.plan_action() must be overridden in subclasses")
    return null

# Helper method to filter abilities that can actually be used in current conditions
# This is provided as a utility for AI implementations
func filter_usable_abilities(enemy: CombatEntity, available_abilities: Array[Ability]) -> Array[Ability]:
    var usable_abilities: Array[Ability] = []
    for ability in available_abilities:
        if ability.can_use(enemy):
            usable_abilities.append(ability)
    return usable_abilities

# Helper method to select a random ability based on priority weighting
# This is provided as a utility for AI implementations
func select_random_ability_by_priority(abilities: Array[Ability]) -> Ability:
    if abilities.is_empty():
        return null

    # Calculate total priority sum
    var total_priority: int = 0
    for ability in abilities:
        total_priority += max(1, ability.priority)  # Ensure minimum priority of 1

    # Pick a random number within the total priority range
    var random_value: int = randi() % total_priority

    # Find the ability that corresponds to this random value
    var current_sum: int = 0
    for ability in abilities:
        current_sum += max(1, ability.priority)
        if random_value < current_sum:
            return ability

    # Fallback to last ability (should not happen)
    return abilities[abilities.size() - 1]

# Categorize abilities by type for strategic AI decision making
# Returns a CategorizedAbilities object with properly typed ability arrays:
# - attack: Offensive damage-dealing abilities
# - defend: Defensive abilities that reduce incoming damage
# - buff: Support abilities that apply temporary enhancements
# - preparation: Multi-turn abilities that build up for stronger effects
# - flee: Escape abilities that attempt to end combat
# - other: Any abilities that don't fit the above categories
func categorize_abilities_by_type(abilities: Array[Ability]) -> CategorizedAbilities:
    var categorized := CategorizedAbilities.new()

    for ability in abilities:
        match ability.get_ability_type():
            Ability.AbilityType.ATTACK:
                categorized.attack.append(ability)
            Ability.AbilityType.DEFEND:
                categorized.defend.append(ability)
            Ability.AbilityType.SUPPORT:
                categorized.buff.append(ability)
            Ability.AbilityType.FLEE:
                categorized.flee.append(ability)
            _:
                categorized.other.append(ability)

    return categorized
