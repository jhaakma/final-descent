class_name ConstantEffectTest extends RefCounted

# Simple test to validate that the constant effect system works correctly
static func run_test() -> void:
    print("Running ConstantEffect test...")

    # Test 1: Verify that ConstantEffect properly identifies itself
    var strength_effect := StrengthBoostEffect.new()
    strength_effect.strength_bonus = 3
    strength_effect.is_removable = true

    assert(strength_effect.get_effect_id() == "strength_boost")
    assert(strength_effect.get_effect_name() == "Strength Boost")
    assert(strength_effect.get_effect_type() == StatusEffect.EffectType.POSITIVE)
    assert(strength_effect.is_expired() == false, "Constant effects should never expire")
    print("✓ StrengthBoostEffect properly configured")

    # Test 2: Verify that ElementalResistanceEffect works
    var fire_resistance := ElementalResistanceEffect.new()
    fire_resistance.elemental_type = DamageType.Type.FIRE
    fire_resistance.is_removable = false

    assert(fire_resistance.get_effect_id() == "fire_resistance")
    assert(fire_resistance.is_permanent() == true, "Non-removable effects should be permanent")
    assert(fire_resistance.get_description().contains("Fire"), "Description should show element type")
    assert(fire_resistance.get_description().contains("Resistance"), "Description should show resistance")
    print("✓ ElementalResistanceEffect properly configured")

    # Test 3: Verify different elemental types work
    var poison_resistance := ElementalResistanceEffect.new()
    poison_resistance.elemental_type = DamageType.Type.POISON
    poison_resistance.is_removable = true

    assert(poison_resistance.get_effect_id() == "poison_resistance")
    assert(poison_resistance.get_effect_name() == "Poison Resistance")
    assert(poison_resistance.get_description().contains("Poison"), "Should show poison type")
    assert(poison_resistance.get_description().contains("Resistance"), "Should show resistance")
    print("✓ Generic elemental types work correctly")

    # Test 4: Check description formatting
    var permanent_desc := fire_resistance.get_base_description()
    assert(permanent_desc.contains("permanent"), "Permanent effects should show in description")

    var removable_desc := strength_effect.get_base_description()
    assert(removable_desc.contains("constant"), "Removable constant effects should show 'constant'")
    print("✓ Description formatting works correctly")

    print("ConstantEffect test completed successfully.")

# Helper function to run the test during development
static func _static_init() -> void:
    # Uncomment to run test on load
    # run_test()
    pass