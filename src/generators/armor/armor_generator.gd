class_name ArmorGenerator extends ItemGenerator
## Generates armor by combining templates, materials, and optional modifiers

@export var armor_templates: Array[Resource] = []  # Should be ArmorTemplate resources
@export var materials: Array[Resource] = []  # Should be ArmorMaterial resources
@export var material_weights: Array[float] = []  # Optional weights for material selection

## Generate armor by combining template and material
func generate_item() -> Item:
    if armor_templates.is_empty() or materials.is_empty():
        push_error("ArmorGenerator requires both armor templates and materials")
        return null

    # Select random template and material
    var template: Resource = armor_templates[GameState.rng.randi_range(0, armor_templates.size() - 1)]
    var material: Resource = _select_material()

    # Create a new armor instance from template
    var generated_armor := Armor.new()
    _apply_template(template, generated_armor)
    _apply_material(material, generated_armor)

    if cache.has(generated_armor.name):
        print("Using cached armor: %s" % generated_armor.name)
        return cache[generated_armor.name]
    else:
        cache[generated_armor.name] = generated_armor

    return generated_armor

## Select a material based on weights or randomly
func _select_material() -> Resource:
    if material_weights.size() == materials.size() and not material_weights.is_empty():
        return _weighted_select_material()
    else:
        return materials[GameState.rng.randi_range(0, materials.size() - 1)]

## Select material using weighted random selection
func _weighted_select_material() -> Resource:
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

## Copy properties from template to generated armor
func _apply_template(template: Resource, target: Armor) -> void:
    # Access ArmorTemplate properties through Resource
    target.name = template.base_name
    target.defense_bonus = template.base_defense
    target.armor_slot = template.armor_slot
    target.condition = template.base_condition
    target.purchase_value = template.base_purchase_value

## Apply material modifiers to the armor
func _apply_material(material: Resource, armor: Armor) -> void:
    # Update armor name with material prefix
    armor.name = "%s %s" % [material.name, armor.name]

    # Apply material modifiers
    armor.defense_bonus = int(armor.defense_bonus * material.defense_modifier)
    armor.condition = int(armor.condition * material.condition_modifier)
    armor.purchase_value = int(armor.purchase_value * material.purchase_value_modifier)

    # Apply material resistances to armor if the material has the resistances property
    var resistances_dict: Variant = material.get("resistances")
    if resistances_dict is Dictionary:
        var typed_resistances: Dictionary = resistances_dict as Dictionary
        if not typed_resistances.is_empty():
            for damage_type: DamageType.Type in typed_resistances.keys():
                var has_resistance: bool = typed_resistances[damage_type]
                armor.set_resistance(damage_type, has_resistance)