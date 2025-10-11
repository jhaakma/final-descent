class_name Player extends CombatEntity

var name: String = "Player"

signal stats_changed
signal inventory_changed
signal death_with_delay  # Emitted when player dies, with delay for UI to show 0 HP
signal death_fade_start  # Emitted immediately when player dies to start fade effect

# Core stats
var gold: int = 0

# Inventory and equipment - using new inventory component
var inventory: ItemInventoryComponent
var equipped_weapon: ItemInstance = null

# Constants for combat calculations
const BASE_ATTACK_MIN: int = 2
const BASE_ATTACK_MAX: int = 5  # This gives 2-5 damage (2 + randi() % 4 gives 2-5)

func _init() -> void:
    # Initialize base combat entity with starting health
    _init_combat_entity(20)

    inventory = ItemInventoryComponent.new()

    # Connect health component signals to player signals
    health_component.health_changed.connect(_on_health_changed)
    health_component.died.connect(_on_health_component_died)
    # Connect inventory signals
    inventory.inventory_changed.connect(_on_inventory_changed)
    reset()

# Reset player to starting state
func reset() -> void:
    if health_component:
        health_component.reset(20)
    gold = 0
    if inventory:
        inventory.clear()
    equipped_weapon = null

    # Clear status effects using inherited component
    clear_all_status_effects()

    emit_signal("stats_changed")
    emit_signal("inventory_changed")

func get_name() -> String:
    return name

# === GOLD MANAGEMENT ===
func has_gold(amount: int) -> bool:
    return gold >= amount

func add_gold(amount: int) -> void:
    gold = max(0, gold + amount)
    emit_signal("stats_changed")

func spend_gold(amount: int) -> bool:
    if has_gold(amount):
        gold -= amount
        emit_signal("stats_changed")
        return true
    return false

# === HEALTH MANAGEMENT ===
func heal(amount: int) -> int:
    return health_component.heal(amount)

func take_damage(amount: int) -> int:
    var defense_bonus := get_total_defense_bonus()
    # Use unified damage calculation through combat actor
    var final_damage: int = calculate_incoming_damage(max(1, amount - defense_bonus))
    return health_component.take_damage(final_damage)

# Health component getters for compatibility
func get_hp() -> int:
    return get_current_hp()

func get_current_hp() -> int:
    return health_component.get_current_hp()

func set_max_hp(new_max_hp: int) -> void:
    health_component.set_max_hp(new_max_hp)

func get_max_hp() -> int:
    # Base max HP plus bonuses from status effects
    return health_component.get_max_hp() + get_total_max_hp_bonus()

# Signal handlers for health component
func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
    emit_signal("stats_changed")

func _on_health_component_died() -> void:
    # Start fade effect immediately
    emit_signal("death_fade_start")
    # Use a timer to delay the death signal so UI can show 0 HP and fade
    var tree := Engine.get_main_loop() as SceneTree
    if tree:
        tree.create_timer(1.0).timeout.connect(func()-> void:  # Increased to 2.5s for fade + delay
            emit_signal("death_with_delay")
        )

# Signal handler for inventory component
func _on_inventory_changed() -> void:
    emit_signal("inventory_changed")

# === INVENTORY MANAGEMENT ===
func add_items(item_instance: ItemInstance) -> void:
    inventory.add_item(item_instance)
    LogManager.log_message("Received item: %s (x%d)" % [item_instance.item.name, item_instance.count])


func remove_item(item_instance: ItemInstance) -> bool:
    if equipped_weapon and item_instance.matches(equipped_weapon):
        unequip_weapon()
    return inventory.remove_item(item_instance)


func has_item(item: Item) -> bool:
    return inventory.has_item(item)

func get_item_count(item: Item) -> int:
    return inventory.get_item_count(item)

# === WEAPON MANAGEMENT ===
func equip_weapon(item_instance: ItemInstance) -> bool:
    var weapon: ItemWeapon = item_instance.item as ItemWeapon
    # Unequip current weapon first if there is one
    if equipped_weapon:
        unequip_weapon()

    # Check if we have this weapon in inventory
    if not inventory.has_item(weapon):
        return false

    if item_instance.item_data:
        # Equipping a specific instance - remove it from inventory
        if inventory.take_item_instance(item_instance.item, item_instance.item_data):
            equipped_weapon = item_instance
            emit_signal("inventory_changed")
    else:
        # Equipping a generic item - take one from stack
        var taken : ItemInstance = inventory.get_item_stack(weapon).take_one()
        if taken:

            equipped_weapon = taken
            emit_signal("inventory_changed")
    equipped_weapon.is_equipped = true
    LogManager.log_message("Equipped %s" % weapon.name)
    return true

func unequip_weapon() -> bool:
    if not equipped_weapon:
        return false

    # Return weapon to inventory based on whether it has unique data
    if equipped_weapon.item_data and equipped_weapon.item_data.is_unique():
        # Has unique data (damaged/enchanted) - add as instance
        inventory.add_item_instance(equipped_weapon)
    else:
        # Undamaged - add as generic item
        inventory.add_item(equipped_weapon)

    LogManager.log_message("Unequipped %s" % equipped_weapon.item.name)

    equipped_weapon.is_equipped = false
    # Clear equipped weapon
    equipped_weapon = null
    emit_signal("inventory_changed")
    return true

func get_equipped_weapon() -> ItemInstance:
    return equipped_weapon

func get_weapon_damage() -> int:
    if equipped_weapon:
        var weapon := equipped_weapon.item as ItemWeapon
        var base_damage := weapon.damage
        if equipped_weapon.item_data:
            # Weapon has taken damage, scale by condition
            var current_condition := equipped_weapon.item_data.current_condition
            var condition_ratio := float(current_condition) / float(weapon.condition)
            return int(base_damage * condition_ratio)
        else:
            # Weapon is undamaged, return full damage
            return base_damage
    return 0

func get_weapon_name() -> String:
    return equipped_weapon.item.name

func has_weapon_equipped() -> bool:
    return equipped_weapon != null

func get_equipped_weapon_instance() -> ItemInstance:
    if equipped_weapon:
        return equipped_weapon
    return null

# Get current weapon condition information
func get_weapon_condition() -> Dictionary:
    if equipped_weapon:
        var weapon := equipped_weapon.item as ItemWeapon
        if equipped_weapon.item_data:
            # Weapon has condition data
            var current_condition := equipped_weapon.item_data.current_condition
            var max_condition := weapon.condition
            return {
                "current": current_condition,
                "max": max_condition,
                "percentage": float(current_condition) / float(max_condition),
                "is_damaged": current_condition < max_condition,
                "is_broken": current_condition <= 0
            }
        else:
            # Weapon is undamaged
            var max_condition := weapon.condition
            return {
                "current": max_condition,
                "max": max_condition,
                "percentage": 1.0,
                "is_damaged": false,
                "is_broken": false
            }
    return {"current": 0, "max": 0, "percentage": 0.0, "is_damaged": false, "is_broken": true}

func get_total_attack_bonus() -> int:
    var total_bonus: int = 0

    # Add bonuses from status effects - generic approach
    for condition in status_effect_component.get_all_conditions():
        if condition.status_effect is StatBoostEffect:
            total_bonus += (condition.status_effect as StatBoostEffect).get_attack_bonus()

    return total_bonus

# Now uses status effects only
func get_total_defense_bonus() -> int:
    var total_bonus: int = 0

    # Add bonuses from status effects - generic approach
    for condition in status_effect_component.get_all_conditions():
        if condition.status_effect is StatBoostEffect:
            total_bonus += (condition.status_effect as StatBoostEffect).get_defense_bonus()

    return total_bonus

# Get total max HP bonus from status effects
func get_total_max_hp_bonus() -> int:
    var total_bonus: int = 0

    # Add bonuses from status effects - generic approach
    for condition in status_effect_component.get_all_conditions():
        if condition.status_effect is StatBoostEffect:
            total_bonus += (condition.status_effect as StatBoostEffect).get_max_hp_bonus()

    return total_bonus

# === STATUS EFFECT MANAGEMENT ===
# Override the base method to emit stats_changed signal for UI updates
func apply_status_effect(effect: StatusEffect) -> bool:
    var result := super.apply_status_effect(effect)
    if result:
        emit_signal("stats_changed")
    return result

func apply_status_condition(condition: StatusCondition) -> bool:
    var result := super.apply_status_condition(condition)
    if result:
        emit_signal("stats_changed")
    return result

# Override the base method to emit stats_changed signal for UI updates
func remove_status_effect(effect: StatusEffect) -> void:
    super.remove_status_effect(effect)
    emit_signal("stats_changed")

func clear_all_negative_status_effects() -> Array[StatusCondition]:
    var removed_effects: Array[StatusCondition] = super.clear_all_negative_status_effects()
    emit_signal("stats_changed")
    return removed_effects

# === COMBAT CALCULATIONS ===
func calculate_attack_damage() -> int:
    var base_dmg := BASE_ATTACK_MIN + randi() % (BASE_ATTACK_MAX - BASE_ATTACK_MIN + 1)
    var weapon_dmg := get_weapon_damage()
    var buff_dmg := get_total_attack_bonus()
    return base_dmg + weapon_dmg + buff_dmg

# Reduce weapon condition after attack - call this after damage logging
func reduce_weapon_condition() -> void:
    if not equipped_weapon:
        return
    var weapon := equipped_weapon.item as ItemWeapon

    # Create ItemData if it doesn't exist yet (first damage)
    if not equipped_weapon.item_data:
        equipped_weapon.item_data = ItemData.new(weapon.condition)
        equipped_weapon.item_data.current_condition = weapon.condition

    var current_condition := equipped_weapon.item_data.current_condition
    current_condition -= 1
    equipped_weapon.item_data.current_condition = current_condition

    # Emit signal to update UI immediately when weapon condition changes
    emit_signal("inventory_changed")

    # Check if weapon is destroyed
    if current_condition <= 0:
        var weapon_name := weapon.name
        LogManager.log_warning("%s has broken and is destroyed!" % weapon_name)
        # Destroy the weapon (don't return it to inventory)
        equipped_weapon = null
        # Emit signal again to update UI when weapon is destroyed
        emit_signal("inventory_changed")

# === STATUS INFORMATION ===
func get_status_summary() -> Dictionary:
    return {
        "hp": health_component.get_current_hp(),
        "max_hp": health_component.get_max_hp(),
        "gold": gold,
        "attack_bonus": get_total_attack_bonus(),
        "defense_bonus": get_total_defense_bonus(),
        "is_defending": get_is_defending(),
        "weapon_damage": get_weapon_damage(),
        "weapon_name": get_weapon_name(),
        "has_weapon": has_weapon_equipped(),
        "active_status_effects_count": status_effect_component.get_effect_count(),
        "active_status_effects": status_effect_component.get_all_conditions()
    }

func get_total_attack_display() -> String:
    # This shows the total attack power for UI display purposes
    # Base damage average + weapon + buffs
    var bonus := get_total_attack_bonus() + get_weapon_damage()
    var min_damage := BASE_ATTACK_MIN + bonus
    var max_damage := BASE_ATTACK_MAX + bonus
    return "%d-%d" % [min_damage, max_damage]

# === INVENTORY COMPATIBILITY METHODS ===
# These provide modern inventory access methods

# Get detailed inventory information for UI display
func get_inventory_display_info() -> Array:
    return inventory.get_inventory_display_info()

# Get ItemTiles for UI display (includes equipped items)
func get_item_tiles() -> Array[ItemInstance]:
    var tiles: Array[ItemInstance] = []

    # Add equipped weapon as a separate tile if present
    if equipped_weapon:
        tiles.append(equipped_weapon)

    # Add inventory tiles
    tiles.append_array(inventory.get_item_tiles())

    return tiles


# Take items and get their ItemData instances
func take_items(item: Item, amount: int = 1) -> Array:
    var taken_items := inventory.take_items(item, amount)
    # Unequip if it's the equipped weapon and there are none left
    if item == equipped_weapon and not inventory.has_item(item):
        unequip_weapon()
    return taken_items
