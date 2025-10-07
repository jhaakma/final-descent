# Player.gd
class_name Player extends RefCounted

signal stats_changed
signal inventory_changed
signal buffs_changed
signal death_with_delay  # Emitted when player dies, with delay for UI to show 0 HP
signal death_fade_start  # Emitted immediately when player dies to start fade effect

# Core stats
var health_component: HealthComponent
var gold: int = 0

# Inventory and equipment - using new inventory component
var inventory: ItemInventoryComponent
var equipped_weapon: ItemWeapon = null
var equipped_weapon_data = null  # ItemData instance for the equipped weapon

# Buff system
var active_buffs: Array[Buff] = []
var buff_attack_bonus: int = 0
var buff_defense_bonus: int = 0

# Status effects
var status_effect_component: StatusEffectComponent = null

# Constants for combat calculations
const BASE_ATTACK_MIN: int = 2
const BASE_ATTACK_MAX: int = 5  # This gives 2-5 damage (2 + randi() % 4 gives 2-5)
const BASE_DEFENSE_WHEN_DEFENDING: int = 2

func _init():
    health_component = HealthComponent.new(20)
    inventory = preload("res://components/item_inventory_component.gd").new()
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
    equipped_weapon_data = null
    active_buffs.clear()
    buff_attack_bonus = 0
    buff_defense_bonus = 0

    # Initialize status effect manager
    if status_effect_component:
        status_effect_component.queue_free()
    status_effect_component = StatusEffectComponent.new()

    emit_signal("stats_changed")
    emit_signal("inventory_changed")
    emit_signal("buffs_changed")

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
func heal(amount: int) -> void:
    health_component.heal(amount)

func take_damage(amount: int) -> int:
    var defense_bonus = get_total_defense_bonus()
    return health_component.take_damage(amount, defense_bonus)

func is_alive() -> bool:
    return health_component.is_alive()

# Health component getters for compatibility
func get_hp() -> int:
    return health_component.get_current_hp()

func get_max_hp() -> int:
    return health_component.get_max_hp()

func set_max_hp(new_max_hp: int) -> void:
    health_component.set_max_hp(new_max_hp)

# Signal handlers for health component
func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
    emit_signal("stats_changed")

func _on_health_component_died() -> void:
    # Start fade effect immediately
    emit_signal("death_fade_start")
    # Use a timer to delay the death signal so UI can show 0 HP and fade
    var tree = Engine.get_main_loop() as SceneTree
    if tree:
        tree.create_timer(1.0).timeout.connect(func():  # Increased to 2.5s for fade + delay
            emit_signal("death_with_delay")
        )

# Signal handler for inventory component
func _on_inventory_changed() -> void:
    emit_signal("inventory_changed")

# === INVENTORY MANAGEMENT ===
func add_item(item: Item) -> void:
    inventory.add_item(item, 1)
    item.on_pickup()

func remove_item(item: Item) -> void:
    inventory.remove_item(item, 1)
    # Only unequip if the equipped weapon is generic (no specific item_data)
    # and there are none left of this item type
    if item == equipped_weapon and not equipped_weapon_data and not inventory.has_item(item):
        unequip_weapon()

# Remove a specific item instance with ItemData
func remove_item_instance(item: Item, item_data) -> bool:
    var success = inventory.remove_item_instance(item, item_data)

    # Unequip if we removed the specific equipped weapon instance
    if success and item == equipped_weapon and equipped_weapon_data == item_data:
        unequip_weapon()

    return success

func has_item(item: Item) -> bool:
    return inventory.has_item(item)

func get_item_count(item: Item) -> int:
    return inventory.get_item_count(item)

# === WEAPON MANAGEMENT ===
func equip_weapon(weapon: ItemWeapon, weapon_data = null) -> void:
    # Unequip current weapon first if there is one
    if equipped_weapon:
        unequip_weapon()

    # Check if we have this weapon in inventory
    if not inventory.has_item(weapon):
        return

    if weapon_data:
        # Equipping a specific instance - remove it from inventory
        if inventory.take_item_instance(weapon, weapon_data):
            equipped_weapon = weapon
            equipped_weapon_data = weapon_data
            emit_signal("inventory_changed")
    else:
        # Equipping a generic item - take one from stack
        var taken_data = inventory.get_item_stack(weapon).take_one()
        if taken_data:
            equipped_weapon = weapon
            equipped_weapon_data = null  # No ItemData until damaged
            emit_signal("inventory_changed")

func unequip_weapon() -> void:
    if not equipped_weapon:
        return

    # Return weapon to inventory based on whether it has unique data
    if equipped_weapon_data and equipped_weapon_data.is_unique():
        # Has unique data (damaged/enchanted) - add as instance
        inventory.add_item_instance(equipped_weapon, equipped_weapon_data)
    else:
        # Undamaged - add as generic item
        inventory.add_item(equipped_weapon, 1)

    # Clear equipped weapon
    equipped_weapon = null
    equipped_weapon_data = null
    emit_signal("inventory_changed")

func get_weapon_damage() -> int:
    if equipped_weapon:
        var base_damage = equipped_weapon.damage
        if equipped_weapon_data:
            # Weapon has taken damage, scale by condition
            var current_condition = equipped_weapon_data.current_condition
            var condition_ratio = float(current_condition) / float(equipped_weapon.condition)
            return int(base_damage * condition_ratio)
        else:
            # Weapon is undamaged, return full damage
            return base_damage
    return 0

func get_weapon_name() -> String:
    return equipped_weapon.name

func has_weapon_equipped() -> bool:
    return equipped_weapon != null

# Get current weapon condition information
func get_weapon_condition() -> Dictionary:
    if equipped_weapon:
        if equipped_weapon_data:
            # Weapon has condition data
            var current_condition = equipped_weapon_data.current_condition
            var max_condition = equipped_weapon.condition
            return {
                "current": current_condition,
                "max": max_condition,
                "percentage": float(current_condition) / float(max_condition),
                "is_damaged": current_condition < max_condition,
                "is_broken": current_condition <= 0
            }
        else:
            # Weapon is undamaged
            var max_condition = equipped_weapon.condition
            return {
                "current": max_condition,
                "max": max_condition,
                "percentage": 1.0,
                "is_damaged": false,
                "is_broken": false
            }
    return {"current": 0, "max": 0, "percentage": 0.0, "is_damaged": false, "is_broken": true}

# === BUFF MANAGEMENT ===
func add_buff(buff: Buff) -> void:
    # Create a copy to avoid modifying the original resource
    var buff_copy = buff.duplicate()
    buff_copy.remaining_duration = buff_copy.duration_turns
    active_buffs.append(buff_copy)
    buff_copy.apply_effects()
    emit_signal("buffs_changed")
    emit_signal("stats_changed")

func remove_buff(buff: Buff) -> void:
    if buff in active_buffs:
        buff.remove_effects()
        active_buffs.erase(buff)
        emit_signal("buffs_changed")
        emit_signal("stats_changed")

func process_buff_turns() -> Array[Buff]:
    var expired_buffs: Array[Buff] = []

    for buff in active_buffs:
        buff.tick_turn()
        if buff.is_expired():
            expired_buffs.append(buff)

    # Remove expired buffs and return them for logging
    for buff in expired_buffs:
        remove_buff(buff)

    return expired_buffs

func get_total_attack_bonus() -> int:
    return buff_attack_bonus

func get_total_defense_bonus() -> int:
    return buff_defense_bonus

func add_temporary_defense_bonus(amount: int) -> void:
    buff_defense_bonus += amount

func remove_temporary_defense_bonus(amount: int) -> void:
    buff_defense_bonus -= amount

# === STATUS EFFECT MANAGEMENT ===
func apply_status_effect(effect: StatusEffect) -> void:
    status_effect_component.apply_effect(effect, self)
    emit_signal("stats_changed")

func has_status_effect(effect_name: String) -> bool:
    return status_effect_component.has_effect(effect_name)

func process_status_effects() -> Array[StatusEffectResult]:
    var results = status_effect_component.process_turn(self)

    # Note: stats_changed signal is automatically emitted by take_damage() and heal()
    # methods when status effects are applied, so no need to emit it here
    return results

func get_status_effect_description(effect_name: String) -> String:
    var status_effect = status_effect_component.get_effect(effect_name)
    if status_effect:
        return status_effect.get_description()
    return ""

func remove_status_effect(effect_name: String) -> void:
    status_effect_component.remove_effect(effect_name)
    emit_signal("stats_changed")

func clear_all_status_effects() -> Array[StatusEffect]:
    var removed_effects = status_effect_component.get_all_effects().duplicate()
    status_effect_component.clear_all_effects()
    emit_signal("stats_changed")
    return removed_effects

func clear_all_negative_status_effects() -> Array[StatusEffect]:
    var removed_effects: Array[StatusEffect] = []
    for effect in status_effect_component.get_all_effects():
        if effect.effect_type == StatusEffect.EffectType.NEGATIVE:
            status_effect_component.remove_effect(effect.effect_name)
            removed_effects.append(effect)
    if removed_effects.size() > 0:
        emit_signal("stats_changed")
    return removed_effects

# Get descriptions of all active status effects
func get_status_effects_description() -> String:
    return status_effect_component.get_effects_description()

# Get all active status effects
func get_all_status_effects() -> Array[StatusEffect]:
    return status_effect_component.get_all_effects()

# === COMBAT CALCULATIONS ===
func calculate_attack_damage() -> int:
    var base_dmg = BASE_ATTACK_MIN + randi() % (BASE_ATTACK_MAX - BASE_ATTACK_MIN + 1)
    var weapon_dmg = get_weapon_damage()
    var buff_dmg = get_total_attack_bonus()
    return base_dmg + weapon_dmg + buff_dmg

# Reduce weapon condition after attack - call this after damage logging
func reduce_weapon_condition() -> void:
    if not equipped_weapon:
        return

    # Create ItemData if it doesn't exist yet (first damage)
    if not equipped_weapon_data:
        equipped_weapon_data = preload("res://components/item_data.gd").new()
        equipped_weapon_data.current_condition = equipped_weapon.condition

    var current_condition = equipped_weapon_data.current_condition
    current_condition -= 1
    equipped_weapon_data.current_condition = current_condition

    # Emit signal to update UI immediately when weapon condition changes
    emit_signal("inventory_changed")

    # Check if weapon is destroyed
    if current_condition <= 0:
        var weapon_name = equipped_weapon.name
        LogManager.log_warning("%s has broken and is destroyed!" % weapon_name)
        # Destroy the weapon (don't return it to inventory)
        equipped_weapon = null
        equipped_weapon_data = null
        # Emit signal again to update UI when weapon is destroyed
        emit_signal("inventory_changed")

func calculate_defend_bonus() -> int:
    return BASE_DEFENSE_WHEN_DEFENDING

# === STATUS INFORMATION ===
func get_status_summary() -> Dictionary:
    return {
        "hp": health_component.get_current_hp(),
        "max_hp": health_component.get_max_hp(),
        "gold": gold,
        "attack_bonus": get_total_attack_bonus(),
        "defense_bonus": get_total_defense_bonus(),
        "weapon_damage": get_weapon_damage(),
        "weapon_name": get_weapon_name(),
        "has_weapon": has_weapon_equipped(),
        "active_buffs_count": active_buffs.size(),
        "active_buffs": active_buffs.duplicate()
    }

func get_total_attack_display() -> String:
    # This shows the total attack power for UI display purposes
    # Base damage average + weapon + buffs
    var bonus = get_total_attack_bonus() + get_weapon_damage()
    var min_damage = BASE_ATTACK_MIN + bonus
    var max_damage = BASE_ATTACK_MAX + bonus
    return "%d-%d" % [min_damage, max_damage]

# === INVENTORY COMPATIBILITY METHODS ===
# These provide compatibility with systems that expect the old inventory format

# Get inventory as Dictionary for compatibility with existing systems
func get_inventory_dict() -> Dictionary:
    return inventory.get_legacy_inventory()

# Get detailed inventory information for UI display
func get_inventory_display_info() -> Array:
    return inventory.get_inventory_display_info()# Get all items in inventory
func get_all_inventory_items() -> Array[Item]:
    return inventory.get_all_items()

# Add item with instance data (for items with condition damage, enchantments, etc.)
func add_item_with_data(item: Item, item_data = null) -> void:
    inventory.add_item_instance(item, item_data)
    if item_data == null:
        item.on_pickup()

# Take items and get their ItemData instances
func take_items(item: Item, amount: int = 1) -> Array:
    var taken_items = inventory.take_items(item, amount)
    # Unequip if it's the equipped weapon and there are none left
    if item == equipped_weapon and not inventory.has_item(item):
        unequip_weapon()
    return taken_items
