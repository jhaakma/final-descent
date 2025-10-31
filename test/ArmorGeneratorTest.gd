class_name ArmorGeneratorTest extends BaseTest

func test_armor_generation_basic() -> bool:
    # Create a simple armor template
    var template := ArmorTemplate.new()
    template.base_name = "Cuirass"
    template.base_defense = 10
    template.armor_slot = Equippable.EquipSlot.CUIRASS
    template.base_condition = 25
    template.base_purchase_value = 50

    # Create a simple armor material
    var material := ArmorMaterial.new()
    material.name = "Iron"
    material.defense_modifier = 1.2
    material.condition_modifier = 1.1
    material.purchase_value_modifier = 1.5

    # Create armor generator
    var generator := ArmorGenerator.new()
    generator.armor_templates = [template]
    generator.materials = [material]

    # Generate armor
    var generated_armor: Item = generator.generate_item()

    # Verify basic properties
    if not generated_armor is Armor:
        return false

    var armor: Armor = generated_armor as Armor
    if armor.name != "Iron Cuirass":
        return false

    if armor.defense_bonus != 12:  # 10 * 1.2
        return false

    if armor.condition != 27:  # 25 * 1.1
        return false

    if armor.purchase_value != 75:  # 50 * 1.5
        return false

    if armor.armor_slot != Equippable.EquipSlot.CUIRASS:
        return false

    return true

func test_armor_resistance_application() -> bool:
    # Create armor template
    var template := ArmorTemplate.new()
    template.base_name = "Shield"
    template.base_defense = 5
    template.armor_slot = Equippable.EquipSlot.SHIELD
    template.base_condition = 20
    template.base_purchase_value = 30

    # Create armor material with resistances
    var material := ArmorMaterial.new()
    material.name = "Dragon Scale"
    material.defense_modifier = 1.5
    material.condition_modifier = 1.0
    material.purchase_value_modifier = 3.0
    material.set_resistance(DamageType.Type.FIRE, true)
    material.set_resistance(DamageType.Type.ICE, true)

    # Create armor generator
    var generator := ArmorGenerator.new()
    generator.armor_templates = [template]
    generator.materials = [material]

    # Generate armor
    var generated_armor: Item = generator.generate_item()
    var armor: Armor = generated_armor as Armor

    # Verify resistances were applied
    if armor.get_resistance(DamageType.Type.FIRE) != true:
        return false

    if armor.get_resistance(DamageType.Type.ICE) != true:
        return false

    if armor.get_resistance(DamageType.Type.POISON) != false:  # Should have no poison resistance
        return false

    if not armor.has_resistances():
        return false

    return true

func test_armor_caching() -> bool:
    # Create template and material
    var template := ArmorTemplate.new()
    template.base_name = "Helmet"
    template.base_defense = 3
    template.armor_slot = Equippable.EquipSlot.HELMET
    template.base_condition = 15
    template.base_purchase_value = 25

    var material := ArmorMaterial.new()
    material.name = "Steel"
    material.defense_modifier = 1.0
    material.condition_modifier = 1.0
    material.purchase_value_modifier = 1.0

    # Create armor generator
    var generator := ArmorGenerator.new()
    generator.armor_templates = [template]
    generator.materials = [material]

    # Generate armor twice
    var armor1: Item = generator.generate_item()
    var armor2: Item = generator.generate_item()

    # Should be the same cached instance
    return armor1 == armor2

func test_weighted_material_selection() -> bool:
    # Create templates
    var template := ArmorTemplate.new()
    template.base_name = "Gloves"
    template.base_defense = 2
    template.armor_slot = Equippable.EquipSlot.GLOVES
    template.base_condition = 10
    template.base_purchase_value = 15

    # Create materials
    var common_material := ArmorMaterial.new()
    common_material.name = "Leather"

    var rare_material := ArmorMaterial.new()
    rare_material.name = "Mithril"

    # Create generator with weighted selection (heavily favor common material)
    var generator := ArmorGenerator.new()
    generator.armor_templates = [template]
    generator.materials = [common_material, rare_material]
    generator.material_weights = [100.0, 1.0]  # 100:1 ratio

    # Generate multiple armors and check distribution
    var common_count := 0
    var _rare_count := 0
    var iterations := 50

    for i in iterations:
        generator.cache.clear()  # Clear cache to force new generation
        var armor: Armor = generator.generate_item() as Armor
        if armor.name.begins_with("Leather"):
            common_count += 1
        elif armor.name.begins_with("Mithril"):
            _rare_count += 1

    # With 100:1 ratio, we should get mostly common materials
    # Allow some variance but expect at least 80% common materials
    return common_count > (iterations * 0.8)