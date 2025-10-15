class_name StatsComponent extends RefCounted

signal died()
signal stats_changed()
signal health_changed(current_health: int, max_health: int)
signal attack_changed(current_attack: int)
signal defense_changed(current_defense: int)

var max_health: int = 20
var attack_power: int = 5
var defense: int = 0

var current_health: int = max_health:
    get:
        return current_health
    set(value):
        current_health = clamp(value, 0, get_total_max_health())
        health_changed.emit(current_health, get_total_max_health())
        if current_health <= 0:
            died.emit()

## Key: ID of the bonus source (e.g. item ID), Value: bonus amount
var health_bonuses: Dictionary[String, int] = {}
## Key: ID of the bonus source (e.g. item ID), Value: bonus amount
var attack_bonuses: Dictionary[String, int] = {}
## Key: ID of the bonus source (e.g. item ID), Value: bonus amount
var defense_bonuses: Dictionary[String, int] = {}


func _init(p_max_health: int = 20, p_attack_power: int = 5, p_defense: int = 0) -> void:
    max_health = p_max_health
    attack_power = p_attack_power
    defense = p_defense
    current_health = max_health

func reset() -> void:
    health_bonuses.clear()
    attack_bonuses.clear()
    defense_bonuses.clear()
    current_health = max_health
    health_changed.emit(current_health, get_total_max_health())
    attack_changed.emit(get_total_attack_power())
    defense_changed.emit(get_total_defense())

    stats_changed.emit()

#== HEALTH MANAGEMENT ===

## Get current health percentage (0.0 to 1.0)
func get_health_percentage() -> float:
    if get_total_max_health() <= 0:
        return 0.0
    return float(current_health) / float(get_total_max_health())


## Get total max health including bonuses
func get_total_max_health() -> int:
    var total_bonus: int = 0
    for bonus: int in health_bonuses.values():
        total_bonus += bonus
    return max_health + total_bonus

## Add a health bonus from a source (e.g. item, buff)
func add_health_bonus(source_id: String, amount: int) -> void:
    health_bonuses[source_id] = amount
    stats_changed.emit()
    current_health += amount
    health_changed.emit(current_health, get_total_max_health())

## Remove a health bonus by source ID
func remove_health_bonus(source_id: String) -> void:
    if health_bonuses.has(source_id):
        health_bonuses.erase(source_id)
        stats_changed.emit()
        current_health = current_health
        health_changed.emit(current_health, get_total_max_health())
    else:
        push_warning("Attempted to remove non-existent health bonus: %s" % source_id)


## Heal the entity, clamped to max health. Returns actual amount healed.
func heal(amount: int) -> int:
    if amount <= 0 or current_health >= get_total_max_health():
        return 0

    current_health += amount
    health_changed.emit(current_health, get_total_max_health())
    return amount

## Take damage directly. Returns actual damage taken.
func take_damage(damage: int) -> int:
    if damage <= 0:
        return 0

    # Apply damage directly (defense is now handled in CombatEntity.calculate_incoming_damage)
    var reduced_damage: int = max(0, damage)

    current_health = max(0, current_health - reduced_damage)
    health_changed.emit(current_health, get_total_max_health())
    return reduced_damage

#== Attack Management ===

## Get total attack power (base + bonuses)
func get_total_attack_power() -> int:
    var total_bonus: int = 0
    for bonus: int in attack_bonuses.values():
        total_bonus += bonus
    return attack_power + total_bonus

## Add an attack bonus from a source (e.g. item, buff)
func add_attack_bonus(source_id: String, amount: int) -> void:
    attack_bonuses[source_id] = amount
    stats_changed.emit()
    attack_changed.emit(get_total_attack_power())

## Remove an attack bonus by source ID
func remove_attack_bonus(source_id: String) -> void:
    if attack_bonuses.has(source_id):
        attack_bonuses.erase(source_id)
        stats_changed.emit()
        attack_changed.emit(get_total_attack_power())
    else:
        push_warning("Attempted to remove non-existent attack bonus: %s" % source_id)


#== Defense Management ===

## Get current defense (including bonuses)
func get_total_defense() -> int:
    var total_bonus: int = 0
    for bonus: int in defense_bonuses.values():
        total_bonus += bonus
    return defense + total_bonus

## Add a defense bonus from a source (e.g. item, buff)
func add_defense_bonus(source_id: String, amount: int) -> void:
    defense_bonuses[source_id] = amount
    stats_changed.emit()
    defense_changed.emit(get_total_defense())

## Remove a defense bonus by source ID
func remove_defense_bonus(source_id: String) -> void:
    if defense_bonuses.has(source_id):
        defense_bonuses.erase(source_id)
        stats_changed.emit()
        defense_changed.emit(get_total_defense())
    else:
        push_warning("Attempted to remove non-existent defense bonus: %s" % source_id)
