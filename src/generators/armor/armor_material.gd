class_name ArmorMaterial extends Resource

@export var name: String = "Leather"
@export var defense_modifier: float = 1.0
@export var condition_modifier: float = 1.0
@export var purchase_value_modifier: float = 1.0

## Dictionary mapping damage types to resistance flags (true = has resistance, false = no resistance)
@export var resistances: Dictionary[DamageType.Type, bool] = {}

## Get resistance for a specific damage type
func get_resistance(damage_type: DamageType.Type) -> bool:
    return resistances.get(damage_type, false)

## Set resistance for a specific damage type
func set_resistance(damage_type: DamageType.Type, has_resistance: bool) -> void:
    if has_resistance:
        resistances[damage_type] = true
    else:
        resistances.erase(damage_type)

## Get all damage types this material provides resistance to
func get_resistances() -> Dictionary:
    return resistances.duplicate()

## Check if this material has any resistances
func has_resistances() -> bool:
    return not resistances.is_empty()