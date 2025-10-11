# enemies/Enemy.gd
class_name Enemy extends CombatEntity

signal action_performed(action_type: Ability.AbilityType, value: int, message: String)

# AI Component for decision making


var resource: EnemyResource
var flee_chance: float = 0.3  # Base flee chance
var planned_ability: Ability = null  # Store the ability planned at start of turn

# Optional inventory for enemies that can carry items
var inventory_component : ItemInventoryComponent = null

func _init(enemy_resource: EnemyResource) -> void:
    resource = enemy_resource

    # Initialize base combat entity with enemy health
    _init_combat_entity(resource.max_hp)

    # Initialize inventory if this enemy should carry items
    # This can be extended based on enemy type or resource configuration
    inventory_component = ItemInventoryComponent.new()

func get_name() -> String:
    return resource.name

# Set the AI component for this enemy
func set_ai_component(new_ai_component: EnemyAIComponent) -> void:
    resource.ai_component = new_ai_component

# Get the current AI component
func get_ai_component() -> EnemyAIComponent:
    return resource.ai_component

func get_attack() -> int:
    return resource.attack

# Enemy AI decision making - call this at the start of turn before damage
# This method delegates to the AI component for intelligent decision making
func plan_action() -> void:
    # Get available abilities from the resource
    var available_abilities: Array[Ability] = get_available_abilities()
    if available_abilities.is_empty():
        # If no abilities available, use legacy system
        planned_ability = null
        return

    # Delegate decision making to the AI component
    planned_ability = resource.ai_component.plan_action(self, available_abilities, health_component.get_hp_percentage())

# Execute the ability that was planned at the start of the turn
func perform_planned_action() -> void:
    # Safety check: verify this entity should not skip their turn (e.g., due to stun)
    # Note: This is primarily a safety check since _enemy_turn() should handle this
    if should_skip_turn():
        LogManager.log_combat("%s is stunned and skips their turn!" % get_name())
        return

    if planned_ability != null:
        planned_ability.execute(self, GameState.player)

        # If the ability is not a multi-turn ability, mark it as completed
        if not planned_ability.is_executing():
            planned_ability.current_state = Ability.AbilityState.COMPLETED
            planned_ability.reset_ability_state()
            planned_ability = null


# Legacy method for backwards compatibility - now checks ability state before planning
func perform_action() -> void:
    # Safety check: verify this entity should not skip their turn (e.g., due to stun)
    # Note: This is primarily a safety check since _enemy_turn() should handle this
    if should_skip_turn():
        LogManager.log_combat("%s is stunned and skips their turn!" % get_name())
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
        plan_action()
        perform_planned_action()


# === ABILITY SYSTEM HELPERS ===
func get_available_abilities() -> Array[Ability]:
    # Get abilities from the resource, combining new abilities with legacy special attacks
    var abilities: Array[Ability] = []

    # Add abilities from the new system if available
    if resource.has_method("get_abilities"):
        abilities.append_array(resource.get_abilities())

    return abilities


# === ABILITY COMPATIBILITY HELPERS ===
# Calculate damage taken considering defense state
func calculate_incoming_damage(base_damage: int) -> int:
    return combat_actor.calculate_incoming_damage(base_damage)

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
