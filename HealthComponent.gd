# HealthComponent.gd
class_name HealthComponent extends RefCounted

# Signals
signal health_changed(current_hp: int, max_hp: int)
signal damage_taken(amount: int, reduced_amount: int)
signal healed(amount: int)
signal died()

# Health properties
var max_hp: int
var current_hp: int

# Defense properties (for damage reduction)
var defense_bonus: int = 0

func _init(starting_max_hp: int = 20) -> void:
	max_hp = starting_max_hp
	current_hp = max_hp

# === CORE HEALTH MANAGEMENT ===

func get_current_hp() -> int:
	return current_hp

func get_max_hp() -> int:
	return max_hp

func get_hp_percentage() -> float:
	if max_hp <= 0:
		return 0.0
	return float(current_hp) / float(max_hp)

func is_alive() -> bool:
	return current_hp > 0

func is_at_full_health() -> bool:
	return current_hp >= max_hp

# === HEALTH MODIFICATION ===

func set_max_hp(new_max_hp: int) -> void:
	max_hp = max(1, new_max_hp)  # Ensure max_hp is at least 1
	current_hp = min(current_hp, max_hp)  # Clamp current HP if it exceeds new max
	health_changed.emit(current_hp, max_hp)

func heal(amount: int) -> int:
	if amount <= 0 or current_hp >= max_hp:
		return 0

	var actual_heal = min(amount, max_hp - current_hp)
	current_hp += actual_heal

	healed.emit(actual_heal)
	health_changed.emit(current_hp, max_hp)
	return actual_heal

func take_damage(damage: int, defense_bonus_override: int = -1) -> int:
	if damage <= 0:
		return 0

	# Use provided defense bonus or the component's default
	var effective_defense = defense_bonus_override if defense_bonus_override >= 0 else defense_bonus
	var reduced_damage = max(1, damage - effective_defense)  # Minimum 1 damage

	current_hp = max(0, current_hp - reduced_damage)

	damage_taken.emit(damage, reduced_damage)
	health_changed.emit(current_hp, max_hp)

	# Check for death
	if current_hp <= 0:
		died.emit()

	return reduced_damage

func set_hp(new_hp: int) -> void:
	var old_hp = current_hp
	current_hp = clamp(new_hp, 0, max_hp)

	if current_hp != old_hp:
		health_changed.emit(current_hp, max_hp)

		if current_hp <= 0 and old_hp > 0:
			died.emit()

# === DEFENSE MANAGEMENT ===

func set_defense_bonus(bonus: int) -> void:
	defense_bonus = max(0, bonus)

func add_defense_bonus(bonus: int) -> void:
	defense_bonus += bonus
	defense_bonus = max(0, defense_bonus)  # Ensure it doesn't go negative

func remove_defense_bonus(bonus: int) -> void:
	defense_bonus -= bonus
	defense_bonus = max(0, defense_bonus)  # Ensure it doesn't go negative

func get_defense_bonus() -> int:
	return defense_bonus

# === UTILITY METHODS ===

func reset(new_max_hp: int = -1) -> void:
	if new_max_hp > 0:
		max_hp = new_max_hp
	current_hp = max_hp
	defense_bonus = 0
	health_changed.emit(current_hp, max_hp)

func get_health_status() -> Dictionary:
	return {
		"current_hp": current_hp,
		"max_hp": max_hp,
		"hp_percentage": get_hp_percentage(),
		"is_alive": is_alive(),
		"is_at_full_health": is_at_full_health(),
		"defense_bonus": defense_bonus
	}

# === COMPATIBILITY METHODS FOR LEGACY CODE ===

# For Player class compatibility
func get_hp() -> int:
	return current_hp

# For Enemy class compatibility
func get_current_health() -> int:
	return current_hp

func get_max_health() -> int:
	return max_hp