class_name ResistanceComponent extends RefCounted

# Resistance multipliers for each damage type
# 0.5 = resistant (half damage), 1.0 = neutral, 2.0 = weak (double damage)
var resistances: Dictionary[DamageType.Type, bool] = {}
var weaknesses: Dictionary[DamageType.Type, bool] = {}

# Standard resistance/weakness multipliers
const RESISTANCE_MULTIPLIER := 0.5
const WEAKNESS_MULTIPLIER := 2.0
const NEUTRAL_MULTIPLIER := 1.0

# Set resistance using predefined constants
func set_resistant_to(damage_type: DamageType.Type) -> void:
    weaknesses.erase(damage_type)
    resistances[damage_type] = true

func set_weak_to(damage_type: DamageType.Type) -> void:
    resistances.erase(damage_type)
    weaknesses[damage_type] = true

func set_neutral_to(damage_type: DamageType.Type) -> void:
    resistances.erase(damage_type)
    weaknesses.erase(damage_type)

# Get the resistance multiplier for a damage type
func get_resistance_multiplier(damage_type: DamageType.Type) -> float:
    if resistances.has(damage_type):
        return RESISTANCE_MULTIPLIER
    elif weaknesses.has(damage_type):
        return WEAKNESS_MULTIPLIER
    else:
        return NEUTRAL_MULTIPLIER

# Check if entity has resistance to a damage type
func is_resistant_to(damage_type: DamageType.Type) -> bool:
    return resistances.has(damage_type)

# Check if entity has weakness to a damage type
func is_weak_to(damage_type: DamageType.Type) -> bool:
    return weaknesses.has(damage_type)

# Calculate final damage after applying resistance
func apply_resistance(base_damage: int, damage_type: DamageType.Type) -> int:
    var multiplier := get_resistance_multiplier(damage_type)
    var final_damage := int(base_damage * multiplier)
    return max(final_damage, 1)  # Minimum 1 damage

func get_resistances() -> Array[DamageType.Type]:
    return resistances.keys()

func get_weaknesses() -> Array[DamageType.Type]:
    return weaknesses.keys()