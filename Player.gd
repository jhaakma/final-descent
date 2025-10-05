# Player.gd
class_name Player extends RefCounted

signal stats_changed
signal inventory_changed
signal buffs_changed
signal death_with_delay  # Emitted when player dies, with delay for UI to show 0 HP
signal death_fade_start  # Emitted immediately when player dies to start fade effect

# Core stats
var max_hp: int = 20
var hp: int = 20
var gold: int = 0

# Inventory and equipment
var inventory: Dictionary[Item, int] = {}
var equipped_weapon: ItemWeapon = null

# Buff system
var active_buffs: Array[Buff] = []
var buff_attack_bonus: int = 0
var buff_defense_bonus: int = 0

# Status effects
var status_effect_manager: StatusEffectManager = null

# Constants for combat calculations
const BASE_ATTACK_MIN: int = 2
const BASE_ATTACK_MAX: int = 5  # This gives 2-5 damage (2 + randi() % 4 gives 2-5)
const BASE_DEFENSE_WHEN_DEFENDING: int = 2

func _init():
    reset()

# Reset player to starting state
func reset() -> void:
    max_hp = 20
    hp = 20
    gold = 0
    inventory.clear()
    equipped_weapon = null
    active_buffs.clear()
    buff_attack_bonus = 0
    buff_defense_bonus = 0

    # Initialize status effect manager
    if status_effect_manager:
        status_effect_manager.queue_free()
    status_effect_manager = StatusEffectManager.new()

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
    hp = clamp(hp + amount, 0, max_hp)
    emit_signal("stats_changed")

func take_damage(amount: int) -> int:
    var defense_bonus = get_total_defense_bonus()
    var reduced_damage = max(1, amount - defense_bonus)  # Minimum 1 damage
    hp = clamp(hp - reduced_damage, 0, max_hp)
    emit_signal("stats_changed")

    # If player died, emit death_with_delay signal after a brief delay
    if hp <= 0:
        # Start fade effect immediately
        emit_signal("death_fade_start")
        # Use a timer to delay the death signal so UI can show 0 HP and fade
        var tree = Engine.get_main_loop() as SceneTree
        if tree:
            tree.create_timer(1.0).timeout.connect(func():  # Increased to 2.5s for fade + delay
                emit_signal("death_with_delay")
            )

    return reduced_damage

func is_alive() -> bool:
    return hp > 0

# === INVENTORY MANAGEMENT ===
func add_item(item: Item) -> void:
    if item in inventory:
        inventory[item] += 1
    else:
        inventory[item] = 1
    emit_signal("inventory_changed")
    item.on_pickup()

func remove_item(item: Item) -> void:
    if item in inventory:
        inventory[item] -= 1
        if inventory[item] <= 0:
            inventory.erase(item)
        emit_signal("inventory_changed")
    # Unequip if it's the equipped weapon and there are none left
    if item == equipped_weapon and item not in inventory:
        unequip_weapon()

func has_item(item: Item) -> bool:
    return item in inventory and inventory[item] > 0

func get_item_count(item: Item) -> int:
    return inventory.get(item, 0)

# === WEAPON MANAGEMENT ===
func equip_weapon(weapon: ItemWeapon) -> void:
    equipped_weapon = weapon
    emit_signal("inventory_changed")  # Refresh inventory display

func unequip_weapon() -> void:
    if equipped_weapon:
        equipped_weapon = null
        emit_signal("inventory_changed")  # Refresh inventory display

func get_weapon_damage() -> int:
    if equipped_weapon:
        return equipped_weapon.damage
    return 0

func get_weapon_name() -> String:
    if equipped_weapon:
        return equipped_weapon.name
    return ""

func has_weapon_equipped() -> bool:
    return equipped_weapon != null

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
    status_effect_manager.apply_effect(effect, self)
    emit_signal("stats_changed")

func has_status_effect(effect_name: String) -> bool:
    return status_effect_manager.has_effect(effect_name)

func process_status_effects() -> Array[StatusEffectResult]:
    var results = status_effect_manager.process_turn(self)

    # Note: stats_changed signal is automatically emitted by take_damage() and heal()
    # methods when status effects are applied, so no need to emit it here
    return results

func get_status_effect_description(effect_name: String) -> String:
    var status_effect = status_effect_manager.get_effect(effect_name)
    if status_effect:
        return status_effect.get_description()
    return ""

func remove_status_effect(effect_name: String) -> void:
    status_effect_manager.remove_effect(effect_name)
    emit_signal("stats_changed")

func clear_all_status_effects() -> Array[StatusEffect]:
    var removed_effects = status_effect_manager.get_all_effects().duplicate()
    status_effect_manager.clear_all_effects()
    emit_signal("stats_changed")
    return removed_effects

func clear_all_negative_status_effects() -> Array[StatusEffect]:
    var removed_effects: Array[StatusEffect] = []
    for effect in status_effect_manager.get_all_effects():
        if effect.effect_type == StatusEffect.EffectType.NEGATIVE:
            status_effect_manager.remove_effect(effect.effect_name)
            removed_effects.append(effect)
    if removed_effects.size() > 0:
        emit_signal("stats_changed")
    return removed_effects

# Get descriptions of all active status effects
func get_status_effects_description() -> String:
    return status_effect_manager.get_effects_description()

# Get all active status effects
func get_all_status_effects() -> Array[StatusEffect]:
    return status_effect_manager.get_all_effects()

# === COMBAT CALCULATIONS ===
func calculate_attack_damage() -> int:
    var base_dmg = BASE_ATTACK_MIN + randi() % (BASE_ATTACK_MAX - BASE_ATTACK_MIN + 1)
    var weapon_dmg = get_weapon_damage()
    var buff_dmg = get_total_attack_bonus()
    return base_dmg + weapon_dmg + buff_dmg

func calculate_defend_bonus() -> int:
    return BASE_DEFENSE_WHEN_DEFENDING

# === STATUS INFORMATION ===
func get_status_summary() -> Dictionary:
    return {
        "hp": hp,
        "max_hp": max_hp,
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
