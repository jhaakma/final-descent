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
var equipped_weapon: ItemInstance = null  # Legacy - will be replaced with equipped_items
var equipped_items: Dictionary = {}  # Maps Equippable.EquipSlot to ItemInstance

# Constants for combat calculations

func _init() -> void:
    # Initialize base combat entity with starting health
    _init_combat_entity(20, 5, 0)

    inventory = ItemInventoryComponent.new()

    # Connect health component signals to player signals
    stats_component.health_changed.connect(_on_health_changed)
    stats_component.died.connect(_on_stats_component_died)
    stats_component.stats_changed.connect(_on_stats_changed)
    # Connect inventory signals
    inventory.inventory_changed.connect(_on_inventory_changed)
    reset()

# Reset player to starting state
func reset() -> void:
    stats_component.reset()
    gold = 0
    if inventory:
        inventory.clear()
    equipped_weapon = null
    equipped_items.clear()

    # Clear status effects using inherited component
    clear_all_status_effects()

    emit_signal("stats_changed")
    emit_signal("inventory_changed")

func get_name() -> String:
    return name

func get_attack_damage_type() -> DamageType.Type:
    if equipped_weapon:
        var weapon := equipped_weapon.item as Weapon
        return weapon.damage_type
    return DamageType.Type.PHYSICAL

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
    return stats_component.heal(amount)

func take_damage(amount: int) -> int:
    # Use unified damage calculation (now includes percentage-based defense)
    var final_damage: int = calculate_incoming_damage(amount)
    var actual_damage_taken: int = stats_component.take_damage(final_damage)

    # Reduce armor condition if actual damage was taken
    if actual_damage_taken > 0:
        reduce_armor_condition()

    return actual_damage_taken

# Health component getters for compatibility
func get_hp() -> int:
    return get_current_hp()

func get_current_hp() -> int:
    return stats_component.current_health

func get_max_hp() -> int:
    # Base max HP plus bonuses from status effects
    return stats_component.get_total_max_health()

# Signal handlers for health component
func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
    pass  # This method exists so we can later handle health changes if needed

func _on_stats_changed() -> void:
    emit_signal("stats_changed")

func _on_stats_component_died() -> void:
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
    LogManager.log_success("Received item: %s (x%d)" % [item_instance.item.name, item_instance.count])


func remove_item(item_instance: ItemInstance) -> bool:
    # If removing an equipped weapon, just clear the equipped reference
    # (equipped items are not in inventory, so we don't need to remove from inventory)
    if equipped_weapon and item_instance.matches(equipped_weapon):
        equipped_weapon.is_equipped = false
        equipped_weapon = null
        emit_signal("inventory_changed")
        return true
    return inventory.remove_item(item_instance)


func has_item(item: Item) -> bool:
    return inventory.has_item(item)

func get_item_count(item: Item) -> int:
    return inventory.get_item_count(item)

# === WEAPON MANAGEMENT ===
func equip_weapon(item_instance: ItemInstance) -> bool:
    var weapon: Weapon = item_instance.item as Weapon
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

    # Initialize enchantment if the weapon has any (on-strike enchantments only)
    if weapon.enchantment:
        weapon.enchantment.initialise(weapon)

    LogManager.log_event("Equipped %s" % weapon.name)
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

    # Weapons only use on-strike enchantments, no cleanup needed on unequip
    LogManager.log_event("Unequipped %s" % equipped_weapon.item.name)

    equipped_weapon.is_equipped = false
    # Clear equipped weapon
    equipped_weapon = null
    emit_signal("inventory_changed")
    return true

func get_equipped_weapon() -> ItemInstance:
    return equipped_weapon

func get_weapon_damage() -> int:
    if equipped_weapon:
        var weapon := equipped_weapon.item as Weapon
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

# === GENERAL EQUIPMENT MANAGEMENT ===
func equip_item(item_instance: ItemInstance) -> bool:
    if not item_instance.item is Equippable:
        return false

    var equippable: Equippable = item_instance.item as Equippable
    var slot: Equippable.EquipSlot = equippable.get_equip_slot()

    # Use legacy weapon system for weapons to maintain compatibility
    if slot == Equippable.EquipSlot.WEAPON:
        return equip_weapon(item_instance)

    # Handle armor equipment
    if equippable is Armor:
        return equip_armor(item_instance)

    return false

func unequip_item(slot: Equippable.EquipSlot) -> bool:
    # Use legacy weapon system for weapons
    if slot == Equippable.EquipSlot.WEAPON:
        return unequip_weapon()

    # Handle armor unequipping
    return unequip_armor(slot)

func get_equipped_item(slot: Equippable.EquipSlot) -> ItemInstance:
    if slot == Equippable.EquipSlot.WEAPON:
        return equipped_weapon
    return equipped_items.get(slot)

func has_item_equipped(slot: Equippable.EquipSlot) -> bool:
    return get_equipped_item(slot) != null

# === ARMOR MANAGEMENT ===
func equip_armor(item_instance: ItemInstance) -> bool:
    if not item_instance.item is Armor:
        return false

    var armor: Armor = item_instance.item as Armor
    var slot: Equippable.EquipSlot = armor.get_equip_slot()

    # Unequip current armor in this slot if there is one
    if equipped_items.has(slot):
        unequip_armor(slot)

    # Check if we have this armor in inventory
    if not inventory.has_item(armor):
        return false

    var equipped_instance: ItemInstance
    if item_instance.item_data:
        # Equipping a specific instance - remove it from inventory
        if inventory.take_item_instance(armor, item_instance.item_data):
            equipped_instance = item_instance
        else:
            return false
    else:
        # Equipping a generic item - take one from stack
        var taken: ItemInstance = inventory.get_item_stack(armor).take_one()
        if taken:
            equipped_instance = taken
        else:
            return false

    equipped_instance.is_equipped = true
    equipped_items[slot] = equipped_instance

    # Apply enchantment effects if the armor has any
    if armor.enchantment:
        armor.enchantment.initialise(armor)
        # Check if it's a constant effect enchantment
        if armor.enchantment is ConstantEffectEnchantment:
            (armor.enchantment as ConstantEffectEnchantment)._on_item_equipped(armor)

    # Apply armor defense bonus
    _apply_armor_defense_bonus(armor)

    LogManager.log_event("Equipped %s" % armor.name)
    emit_signal("inventory_changed")
    return true

func unequip_armor(slot: Equippable.EquipSlot) -> bool:
    if not equipped_items.has(slot):
        return false

    var equipped_instance: ItemInstance = equipped_items[slot]
    var armor: Armor = equipped_instance.item as Armor

    # Return armor to inventory based on whether it has unique data
    if equipped_instance.item_data and equipped_instance.item_data.is_unique():
        # Has unique data (damaged/enchanted) - add as instance
        inventory.add_item_instance(equipped_instance)
    else:
        # Undamaged - add as generic item
        inventory.add_item(equipped_instance)

    # Remove enchantment effects if the armor has any
    if armor.enchantment:
        # Check if it's a constant effect enchantment
        if armor.enchantment is ConstantEffectEnchantment:
            (armor.enchantment as ConstantEffectEnchantment)._on_item_unequipped(armor)

    # Remove armor defense bonus
    _remove_armor_defense_bonus(armor)

    LogManager.log_event("Unequipped %s" % armor.name)

    equipped_instance.is_equipped = false
    equipped_items.erase(slot)
    emit_signal("inventory_changed")
    return true

func get_equipped_armor(slot: Equippable.EquipSlot) -> ItemInstance:
    return equipped_items.get(slot)

func get_all_equipped_items() -> Array[ItemInstance]:
    var items: Array[ItemInstance] = []

    # Add legacy weapon
    if equipped_weapon:
        items.append(equipped_weapon)

    # Add equipped armor
    for item_instance: ItemInstance in equipped_items.values():
        items.append(item_instance)

    return items

# Calculate total defense bonus from all equipped armor
func get_total_armor_defense_bonus() -> int:
    var total_bonus: int = 0

    for item_instance: ItemInstance in equipped_items.values():
        if item_instance.item is Armor:
            var armor: Armor = item_instance.item as Armor
            total_bonus += armor.get_defense_bonus()

    return total_bonus

# Apply armor defense bonus to stats component
func _apply_armor_defense_bonus(armor: Equippable) -> void:
    if armor is Armor:
        var armor_item: Armor = armor as Armor
        var source_id: String = "armor_%s" % armor.get_equip_slot_name().to_lower()
        stats_component.add_defense_bonus(source_id, armor_item.get_defense_bonus())

# Remove armor defense bonus from stats component
func _remove_armor_defense_bonus(armor: Equippable) -> void:
    var source_id: String = "armor_%s" % armor.get_equip_slot_name().to_lower()
    stats_component.remove_defense_bonus(source_id)

# Get current weapon condition information
func get_weapon_condition() -> Dictionary:
    if equipped_weapon:
        var weapon := equipped_weapon.item as Weapon
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

# Get total max HP bonus from status effects
func get_total_max_hp_bonus() -> int:
    return stats_component.get_total_max_health() - stats_component.max_health

# === DEFENSE MANAGEMENT ===
# Override to ensure UI displays correct defense including armor
func get_total_defense() -> int:
    return stats_component.get_total_defense()

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

func remove_status_condition(condition_name: String) -> bool:
    var result := super.remove_status_condition(condition_name)
    if result:
        emit_signal("stats_changed")
    return result

func clear_all_negative_status_effects() -> Array[StatusCondition]:
    var removed_effects: Array[StatusCondition] = super.clear_all_negative_status_effects()
    emit_signal("stats_changed")
    return removed_effects

# === COMBAT CALCULATIONS ===
# Override to include weapon damage in total attack power
func get_total_attack_power() -> int:
    var base_attack := super.get_total_attack_power()  # Get base + bonuses from stats
    var weapon_damage := get_weapon_damage()  # Get weapon damage
    return base_attack + weapon_damage

func calculate_attack_damage() -> int:
    # Deprecated: Use get_total_attack_power() instead
    # Now that get_total_attack_power() includes weapon damage, we can just use that
    return get_total_attack_power()

# Reduce weapon condition after attack - call this after damage logging
func reduce_weapon_condition() -> void:
    if not equipped_weapon:
        return
    var weapon := equipped_weapon.item as Weapon

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
        LogManager.log_event("%s has broken and is destroyed!" % weapon_name)
        # Destroy the weapon (don't return it to inventory)
        equipped_weapon = null
        # Emit signal again to update UI when weapon is destroyed
        emit_signal("inventory_changed")

# Reduce armor condition after taking damage - call this after damage calculation
func reduce_armor_condition() -> void:
    # Get all equipped armor items
    var armor_items_to_remove: Array[Equippable.EquipSlot] = []

    for slot: Equippable.EquipSlot in equipped_items.keys():
        var equipped_instance: ItemInstance = equipped_items[slot]
        if not equipped_instance or not equipped_instance.item is Armor:
            continue

        var armor := equipped_instance.item as Armor

        # Create ItemData if it doesn't exist yet (first damage)
        if not equipped_instance.item_data:
            equipped_instance.item_data = ItemData.new(armor.condition)
            equipped_instance.item_data.current_condition = armor.condition

        var current_condition := equipped_instance.item_data.current_condition
        current_condition -= 1
        equipped_instance.item_data.current_condition = current_condition

        # Check if armor is destroyed
        if current_condition <= 0:
            var armor_name := armor.name
            LogManager.log_event("%s has broken and is destroyed!" % armor_name)
            armor_items_to_remove.append(slot)

    # Remove destroyed armor items (do this after iteration to avoid modifying dict during iteration)
    for slot: Equippable.EquipSlot in armor_items_to_remove:
        unequip_item(slot)

    # Emit signal to update UI if any armor condition changed or was destroyed
    if equipped_items.size() > 0 or armor_items_to_remove.size() > 0:
        emit_signal("inventory_changed")

func get_total_attack_display() -> String:
    # This shows the total attack power for UI display purposes
    # Now uses the unified get_total_attack_power() method
    return "%d" % get_total_attack_power()

# === INVENTORY COMPATIBILITY METHODS ===
# These provide modern inventory access methods

# Get detailed inventory information for UI display
func get_inventory_display_info() -> Array:
    return inventory.get_inventory_display_info()

# Get ItemTiles for UI display (includes equipped items for shop/combat contexts)
func get_item_tiles() -> Array[ItemInstance]:
    var tiles: Array[ItemInstance] = []

    # Add equipped weapon as a separate tile if present
    if equipped_weapon:
        tiles.append(equipped_weapon)

    # Add equipped armor
    for item_instance: ItemInstance in equipped_items.values():
        tiles.append(item_instance)

    # Add inventory tiles
    tiles.append_array(inventory.get_item_tiles())

    return tiles

# Get ItemTiles for inventory display only (excludes equipped items)
func get_inventory_tiles() -> Array[ItemInstance]:
    return inventory.get_item_tiles()


# Take items and get their ItemData instances
func take_items(item: Item, amount: int = 1) -> Array:
    var taken_items := inventory.take_items(item, amount)
    # Unequip if it's the equipped weapon and there are none left
    if item == equipped_weapon and not inventory.has_item(item):
        unequip_weapon()
    return taken_items
