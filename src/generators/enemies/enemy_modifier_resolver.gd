class_name EnemyModifierResolver extends RefCounted
## Utility class for selecting modifiers from a pool using weighted random selection

## Select a random modifier from a pool using weighted selection based on rarity
static func select_random_modifier(modifier_pool: Array[EnemyModifier]) -> EnemyModifier:
    if modifier_pool.is_empty():
        return null

    # Calculate total weight
    var total_weight: float = 0.0
    for modifier: EnemyModifier in modifier_pool:
        total_weight += modifier.rarity_weight

    # Select using weighted random
    var random_value := GameState.rng.randf() * total_weight
    var current_weight: float = 0.0

    for modifier: EnemyModifier in modifier_pool:
        current_weight += modifier.rarity_weight
        if random_value <= current_weight:
            return modifier

    # Fallback to first modifier
    return modifier_pool[0]