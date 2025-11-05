# enemies/Enemy.gd
class_name Enemy extends CombatEntity

# AI Component for decision making


var resource: EnemyResource
var flee_chance: float = 0.3  # Base flee chance
var planned_ability: AbilityInstance = null  # Store the ability instance planned at start of turn
var ability_instances: Array[AbilityInstance] = []  # Instance objects created from ability resources

# Optional inventory for enemies that can carry items
var inventory_component : ItemInventoryComponent = null

func _init(enemy_resource: EnemyResource) -> void:
    resource = enemy_resource

    # Initialize base combat entity with enemy health
    _init_combat_entity(resource.max_hp, resource.attack, resource.defense)

    # Apply resistances and weaknesses from resource
    _apply_resistances_and_weaknesses()

    # Initialize ability instances from ability resources
    _initialize_ability_instances()

    # Initialize inventory if this enemy should carry items
    # This can be extended based on enemy type or resource configuration
    inventory_component = ItemInventoryComponent.new()

# Apply resistances and weaknesses defined in the enemy resource
func _apply_resistances_and_weaknesses() -> void:
    for resistance_type: DamageType.Type in resource.resistances:
        set_resistant_to(resistance_type)

    for weakness_type: DamageType.Type in resource.weaknesses:
        set_weak_to(weakness_type)

# Initialize ability instances from the ability resources
func _initialize_ability_instances() -> void:
    ability_instances.clear()
    for ability_resource: AbilityResource in resource.get_abilities():
        var instance: AbilityInstance = AbilityInstance.new(ability_resource)
        ability_instances.append(instance)

func get_name() -> String:
    return resource.name

func get_attack_damage_type() -> DamageType.Type:
    # Enemies default to blunt damage unless overridden by abilities
    return DamageType.Type.BLUNT

# Set the AI component for this enemy
func set_ai_component(new_ai_component: EnemyAIComponent) -> void:
    resource.ai_component = new_ai_component

# Get the current AI component
func get_ai_component() -> EnemyAIComponent:
    return resource.ai_component

# Enemy AI decision making - call this at the start of turn before damage
# This method delegates to the AI component for intelligent decision making
func plan_action() -> void:
    # Get available ability instances
    var available_abilities: Array[AbilityInstance] = get_available_ability_instances()
    if available_abilities.is_empty():
        # If no abilities available, create a basic attack as fallback
        planned_ability = _create_fallback_attack_instance()
        return

    if not available_abilities.is_empty():
        planned_ability = resource.ai_component.plan_action(self, available_abilities, stats_component.get_health_percentage())
    else:
        # Fallback to a basic attack if no abilities are available
        planned_ability = _create_fallback_attack_instance()

# Execute the ability that was planned at the start of the turn
func perform_planned_action() -> void:
    # Safety check: verify this entity should not skip their turn (e.g., due to stun)
    # Note: This is primarily a safety check since _enemy_turn() should handle this
    if should_skip_turn():
        LogManager.log_event("{You are} {action} stunned and {action} {your} turn!" % [], {"target": self, "action": ["skip", "skips"]})
        return

    if planned_ability != null:
        planned_ability.execute(self, GameState.player)

        # If the ability is not a multi-turn ability, mark it as completed
        if not planned_ability.is_executing():
            planned_ability.current_state = AbilityInstance.AbilityState.COMPLETED
            planned_ability.reset_ability_state()
            planned_ability = null


# Legacy method for backwards compatibility - now checks ability state before planning
func perform_action() -> void:
    # Safety check: verify this entity should not skip their turn (e.g., due to stun)
    # Note: This is primarily a safety check since _enemy_turn() should handle this
    if should_skip_turn():
        LogManager.log_event("{You are} stunned and {action} {your} turn!" % [], {"target": self, "action": ["skip", "skips"]})
        return

    # Check if we have an ability that's currently executing (multi-turn)
    if planned_ability != null and planned_ability.is_executing():
        # Continue the current ability's execution
        planned_ability.continue_execution()

        # If the ability is now completed, reset it
        if planned_ability.is_completed():
            planned_ability.reset_ability_state()
            planned_ability = null
    else:
        # No ongoing ability, plan and execute a new one
        # First reduce cooldowns on all abilities
        _reduce_ability_cooldowns()
        plan_action()
        perform_planned_action()


func get_available_ability_instances() -> Array[AbilityInstance]:
    # Get ability instances that are available to use
    var available: Array[AbilityInstance] = []

    for instance: AbilityInstance in ability_instances:
        if instance.is_available(self):
            available.append(instance)

    return available

# Reduce cooldowns for all ability instances
func _reduce_ability_cooldowns() -> void:
    for instance: AbilityInstance in ability_instances:
        instance.reduce_cooldown()

# Create a fallback basic attack when enemy has no abilities configured
func _create_fallback_attack_instance() -> AbilityInstance:
    var attack_resource := AttackAbility.new()
    attack_resource.ability_name = "Attack"
    attack_resource.description = "A basic attack"
    attack_resource.base_damage = 0  # Will use enemy's attack stat
    attack_resource.damage_variance = 2
    attack_resource.priority = 10

    return AbilityInstance.new(attack_resource)


# === INVENTORY MANAGEMENT ===
# Methods for managing enemy inventory and loot

# Add an item to this enemy's inventory
func add_item(item: Item, amount: int = 1) -> bool:
    if inventory_component:
        return inventory_component.add_item(ItemInstance.new(item, null, amount))
    return false


# Check if enemy has an item
func has_item(item: Item, amount: int = 1) -> bool:
    if inventory_component:
        return inventory_component.has_item(item, amount)
    return false

# Get count of an item
func get_item_count(item: Item) -> int:
    if inventory_component:
        return inventory_component.get_item_count(item)
    return 0


# Drop specific items (remove from inventory and return ItemData instances)
func drop_items(item: Item, amount: int = 1) -> Array:
    if inventory_component:
        return inventory_component.take_items(item, amount)
    return []

# Get detailed inventory for UI or loot display
func get_inventory_display_info() -> Array:
    if inventory_component:
        return inventory_component.get_inventory_display_info()
    return []

# Get ItemTiles for UI display
func get_item_tiles() -> Array[ItemInstance]:
    if inventory_component:
        return inventory_component.get_item_tiles()
    return []
