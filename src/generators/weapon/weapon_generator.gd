class_name WeaponGenerator extends ItemGenerator
## Generates weapons by combining templates, materials, and optional modifiers

@export var weapon_templates: Array[WeaponTemplate] = []
@export var materials: Array[WeaponMaterial] = []
@export var material_weights: Array[float] = []  # Optional weights for material selection

## Generate a weapon by combining template and material
func generate_item() -> Item:
    if weapon_templates.is_empty() or materials.is_empty():
        push_error("WeaponGenerator requires both weapon templates and materials")
        return null

    # Select random template and material
    var template: Resource = weapon_templates[GameState.rng.randi_range(0, weapon_templates.size() - 1)]
    var material := _select_material()

    # Create a new weapon instance from template
    var generated_weapon := Weapon.new()
    _apply_template(template, generated_weapon)
    _apply_material(material, generated_weapon)

    return generated_weapon

## Select a material based on weights or randomly
func _select_material() -> WeaponMaterial:
    if material_weights.size() == materials.size() and not material_weights.is_empty():
        return _weighted_select_material()
    else:
        return materials[GameState.rng.randi_range(0, materials.size() - 1)]

## Select material using weighted random selection
func _weighted_select_material() -> WeaponMaterial:
    var total_weight: float = 0.0
    for weight in material_weights:
        total_weight += weight

    var random_value := GameState.rng.randf() * total_weight
    var current_weight: float = 0.0

    for i in materials.size():
        current_weight += material_weights[i]
        if random_value <= current_weight:
            return materials[i]

    # Fallback to last material
    return materials[materials.size() - 1]

## Copy properties from template to generated weapon
func _apply_template(template: WeaponTemplate, target: Weapon) -> void:
    # Access WeaponTemplate properties through Resource
    target.name = template.base_name
    target.damage = template.base_damage
    target.damage_type = template.damage_type
    # Set default values for other properties
    target.condition = template.base_condition
    target.purchase_value = template.base_purchase_value

## Apply material modifiers to the weapon
func _apply_material(material: WeaponMaterial, weapon: Weapon) -> void:
    # Update weapon name with material prefix
    weapon.name = "%s %s" % [material.name, weapon.name]

    # Apply material modifiers
    weapon.damage = int(weapon.damage * material.damage_modifier)
    weapon.condition = int(weapon.condition * material.condition_modifier)
    weapon.purchase_value = int(weapon.purchase_value * material.purchase_value_modifier)
