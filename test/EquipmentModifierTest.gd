extends BaseTest
class_name EquipmentModifierTest

func test_modifier_creation() -> bool:
    var modifier := EquipmentModifier.new()
    modifier.modifier_name = "Refined"
    modifier.name_prefix = "Refined"
    modifier.damage_modifier = 1.1
    modifier.defense_modifier = 1.1
    modifier.condition_modifier = 1.2

    assert_equals(modifier.modifier_name, "Refined", "Modifier name should be set")
    assert_equals(modifier.damage_modifier, 1.1, "Damage modifier should be 1.1")
    assert_equals(modifier.defense_modifier, 1.1, "Defense modifier should be 1.1")
    assert_equals(modifier.condition_modifier, 1.2, "Condition modifier should be 1.2")

    return true

func test_modifier_weapon_restrictions() -> bool:
    # Create a modifier that only applies to slashing/piercing weapons
    var sharpened := EquipmentModifier.new()
    sharpened.modifier_name = "Sharpened"
    sharpened.allowed_damage_types = [DamageType.Type.SLASHING, DamageType.Type.PIERCING]

    # Create test weapons
    var sword := Weapon.new()
    sword.name = "Sword"
    sword.damage_type = DamageType.Type.SLASHING

    var dagger := Weapon.new()
    dagger.name = "Dagger"
    dagger.damage_type = DamageType.Type.PIERCING

    var mace := Weapon.new()
    mace.name = "Mace"
    mace.damage_type = DamageType.Type.BLUNT

    # Test restrictions
    assert_true(sharpened.can_apply_to_weapon(sword), "Sharpened should apply to slashing weapons")
    assert_true(sharpened.can_apply_to_weapon(dagger), "Sharpened should apply to piercing weapons")
    assert_false(sharpened.can_apply_to_weapon(mace), "Sharpened should NOT apply to blunt weapons")

    return true

func test_modifier_armor_restrictions() -> bool:
    # Create a modifier that only applies to armor
    var reinforced := EquipmentModifier.new()
    reinforced.modifier_name = "Reinforced"
    reinforced.allowed_item_types = [
        Equippable.EquipSlot.CUIRASS,
        Equippable.EquipSlot.HELMET,
        Equippable.EquipSlot.GLOVES,
        Equippable.EquipSlot.BOOTS,
        Equippable.EquipSlot.SHIELD
    ]

    # Create test armor
    var cuirass := Armor.new()
    cuirass.name = "Cuirass"
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS

    var helmet := Armor.new()
    helmet.name = "Helmet"
    helmet.armor_slot = Equippable.EquipSlot.HELMET

    # Create test weapon (should not be allowed)
    var sword := Weapon.new()
    sword.name = "Sword"

    assert_true(reinforced.can_apply_to_armor(cuirass), "Reinforced should apply to cuirass")
    assert_true(reinforced.can_apply_to_armor(helmet), "Reinforced should apply to helmet")
    assert_false(reinforced.can_apply_to_weapon(sword), "Reinforced should NOT apply to weapons")

    return true

func test_modifier_forbidden_slots() -> bool:
    # Create a modifier that cannot be applied to shields
    var lightweight := EquipmentModifier.new()
    lightweight.modifier_name = "Lightweight"
    lightweight.forbidden_item_types = [Equippable.EquipSlot.SHIELD]

    var cuirass := Armor.new()
    cuirass.armor_slot = Equippable.EquipSlot.CUIRASS

    var shield := Armor.new()
    shield.armor_slot = Equippable.EquipSlot.SHIELD

    assert_true(lightweight.can_apply_to_armor(cuirass), "Lightweight should apply to cuirass")
    assert_false(lightweight.can_apply_to_armor(shield), "Lightweight should NOT apply to shield")

    return true

func test_apply_modifier_to_weapon() -> bool:
    # Create a weapon
    var sword := Weapon.new()
    sword.name = "Sword"
    sword.damage = 10
    sword.condition = 20

    # Create and apply a modifier
    var sharpened := EquipmentModifier.new()
    sharpened.modifier_name = "Sharpened"
    sharpened.name_prefix = "Sharpened"
    sharpened.damage_modifier = 1.2
    sharpened.condition_modifier = 0.9

    assert_true(sword.can_have_modifier(), "Sword should be able to have a modifier")
    assert_true(sword.apply_modifier(sharpened), "Modifier should be applied successfully")

    # Check that stats were updated
    assert_equals(sword.damage, 12, "Damage should be increased to 12")
    assert_equals(sword.condition, 18, "Condition should be reduced to 18")
    assert_equals(sword.name, "Sharpened Sword", "Name should include prefix")

    # Check that a second modifier cannot be applied
    assert_false(sword.can_have_modifier(), "Sword should not accept another modifier")

    return true

func test_apply_modifier_to_armor() -> bool:
    # Create armor
    var cuirass := Armor.new()
    cuirass.name = "Cuirass"
    cuirass.defense_bonus = 10
    cuirass.condition = 25

    # Create and apply a modifier
    var reinforced := EquipmentModifier.new()
    reinforced.modifier_name = "Reinforced"
    reinforced.name_prefix = "Reinforced"
    reinforced.defense_modifier = 1.3
    reinforced.condition_modifier = 1.5

    assert_true(cuirass.can_have_modifier(), "Cuirass should be able to have a modifier")
    assert_true(cuirass.apply_modifier(reinforced), "Modifier should be applied successfully")

    # Check that stats were updated
    assert_equals(cuirass.defense_bonus, 13, "Defense should be increased to 13")
    assert_equals(cuirass.condition, 37, "Condition should be increased to 37")
    assert_equals(cuirass.name, "Reinforced Cuirass", "Name should include prefix")

    return true

func test_modifier_name_with_suffix() -> bool:
    var sword := Weapon.new()
    sword.name = "Sword"

    var modifier := EquipmentModifier.new()
    modifier.modifier_name = "of Sharpness"
    modifier.name_prefix = ""  # Clear the default prefix
    modifier.name_suffix = "of Sharpness"

    sword.apply_modifier(modifier)

    assert_equals(sword.name, "Sword of Sharpness", "Name should include suffix")

    return true

func test_modifier_description() -> bool:
    var modifier := EquipmentModifier.new()
    modifier.damage_modifier = 1.2  # +20%
    modifier.defense_modifier = 1.1  # +10%
    modifier.condition_modifier = 0.9  # -10%

    var description: String = modifier.get_description()

    assert_string_contains(description, "+20% Damage", "Description should mention damage bonus")
    assert_string_contains(description, "+10% Defense", "Description should mention defense bonus")
    assert_string_contains(description, "-10% Durability", "Description should mention durability penalty")

    return true

func test_modifier_tooltip_display() -> bool:
    var sword := Weapon.new()
    sword.name = "Sword"
    sword.damage = 10

    var sharpened := EquipmentModifier.new()
    sharpened.modifier_name = "Sharpened"
    sharpened.name_prefix = "Sharpened"
    sharpened.damage_modifier = 1.2

    sword.apply_modifier(sharpened)

    var tooltip_info: Array = sword.get_additional_tooltip_info()
    assert_true(tooltip_info.size() > 0, "Tooltip info should not be empty")

    # Find the modifier info
    var has_modifier_info: bool = false
    for i in range(tooltip_info.size()):
        var info: Item.AdditionalTooltipInfoData = tooltip_info[i] as Item.AdditionalTooltipInfoData
        if info and info.text.contains("Sharpened"):
            has_modifier_info = true
            break

    assert_true(has_modifier_info, "Tooltip should contain modifier information")

    return true

func test_blacksmith_repair_cost() -> bool:
    var blacksmith := BlacksmithRoomResource.new()
    blacksmith.repair_cost_per_condition = 2

    var sword := Weapon.new()
    sword.name = "Damaged Sword"
    sword.condition = 20

    # Create item data with reduced condition
    var item_data := ItemData.new(20)
    item_data.current_condition = 10  # 10 condition missing

    var cost: int = blacksmith.calculate_repair_cost(sword, item_data)

    assert_equals(cost, 20, "Repair cost should be 20 (10 condition * 2 gold each)")

    return true

func test_blacksmith_repair_functionality() -> bool:
    # Initialize GameState
    if not GameState.player:
        GameState.player = Player.new()
    GameState.player.reset()
    GameState.player.add_gold(100)

    var blacksmith := BlacksmithRoomResource.new()
    blacksmith.repair_cost_per_condition = 2

    var sword := Weapon.new()
    sword.name = "Damaged Sword"
    sword.condition = 20

    var item_data := ItemData.new(20)
    item_data.current_condition = 10

    var item_instance := ItemInstance.new(sword, item_data, 1)

    # Repair the item
    assert_true(blacksmith.repair_item(item_instance), "Repair should succeed")
    assert_equals(item_instance.item_data.current_condition, 20, "Item should be fully repaired")
    assert_equals(GameState.player.gold, 80, "Gold should be deducted")

    return true

func test_blacksmith_upgrade_functionality() -> bool:
    # Initialize GameState
    if not GameState.player:
        GameState.player = Player.new()
    GameState.player.reset()
    GameState.player.add_gold(100)

    var blacksmith := BlacksmithRoomResource.new()
    blacksmith.upgrade_cost = 50

    # Create a modifier
    var refined := EquipmentModifier.new()
    refined.modifier_name = "Refined"
    refined.name_prefix = "Refined"
    refined.damage_modifier = 1.1

    blacksmith.available_modifiers = [refined]

    var sword := Weapon.new()
    sword.name = "Sword"
    sword.damage = 10

    var item_instance := ItemInstance.new(sword, null, 1)

    # Upgrade the item
    assert_true(blacksmith.upgrade_item(item_instance), "Upgrade should succeed")

    # Check the upgraded item (not the original sword, which is unchanged)
    var upgraded_sword := item_instance.item as Weapon
    assert_false(upgraded_sword.can_have_modifier(), "Upgraded sword should now have a modifier")
    assert_equals(GameState.player.gold, 50, "Gold should be deducted")

    return true

func test_cannot_upgrade_already_modified_item() -> bool:
    # Initialize GameState
    if not GameState.player:
        GameState.player = Player.new()
    GameState.player.reset()
    GameState.player.add_gold(100)

    var blacksmith := BlacksmithRoomResource.new()
    blacksmith.upgrade_cost = 50

    var refined := EquipmentModifier.new()
    refined.modifier_name = "Refined"

    blacksmith.available_modifiers = [refined]

    var sword := Weapon.new()
    sword.name = "Sword"

    # Apply a modifier directly
    sword.apply_modifier(refined)

    var item_instance := ItemInstance.new(sword, null, 1)

    # Try to upgrade again
    assert_false(blacksmith.upgrade_item(item_instance), "Cannot upgrade already modified item")
    assert_equals(GameState.player.gold, 100, "Gold should not be deducted")

    return true

func test_modifier_color_in_inventory() -> bool:
    var sword := Weapon.new()
    sword.name = "Sword"

    var base_color: Color = sword.get_inventory_color()

    var refined := EquipmentModifier.new()
    refined.modifier_name = "Refined"
    sword.apply_modifier(refined)

    var modified_color: Color = sword.get_inventory_color()

    assert_true(base_color != modified_color, "Modified items should have different color")

    return true

func test_blacksmith_scales_current_condition_on_upgrade() -> bool:
    # Initialize GameState
    if not GameState.player:
        GameState.player = Player.new()
    GameState.player.reset()
    GameState.player.add_gold(100)

    var blacksmith := BlacksmithRoomResource.new()
    blacksmith.upgrade_cost = 50

    # Create a modifier that increases condition
    var reinforced := EquipmentModifier.new()
    reinforced.modifier_name = "Reinforced"
    reinforced.name_prefix = "Reinforced"
    reinforced.condition_modifier = 1.5  # +50% condition

    blacksmith.available_modifiers = [reinforced]

    var sword := Weapon.new()
    sword.name = "Sword"
    sword.condition = 20

    # Create item data with current condition at 50% (10/20)
    var item_data := ItemData.new(20)
    item_data.current_condition = 10

    var item_instance := ItemInstance.new(sword, item_data, 1)

    # Upgrade the item
    assert_true(blacksmith.upgrade_item(item_instance), "Upgrade should succeed")

    # Check the upgraded item (not the original, which is unchanged)
    var upgraded_sword := item_instance.item as Weapon
    assert_equals(upgraded_sword.condition, 30, "Max condition should be 30 (20 * 1.5)")

    # Check that current condition was scaled proportionally (10/20 = 50%, so 15/30 = 50%)
    assert_equals(item_instance.item_data.current_condition, 15, "Current condition should be scaled to 15")

    return true

func test_modifier_restrictions_prevent_invalid_upgrades() -> bool:
    # Create a modifier that only applies to slashing weapons
    var sharpened := EquipmentModifier.new()
    sharpened.modifier_name = "Sharpened"
    sharpened.name_prefix = "Sharpened"
    sharpened.allowed_damage_types = [DamageType.Type.SLASHING]

    # Create a blunt weapon (mace)
    var mace := Weapon.new()
    mace.name = "Mace"
    mace.damage_type = DamageType.Type.BLUNT

    # Sharpened should not be applicable to blunt weapons
    assert_false(sharpened.can_apply_to_weapon(mace), "Sharpened should not apply to blunt weapons")

    # Create a slashing weapon (sword)
    var sword := Weapon.new()
    sword.name = "Sword"
    sword.damage_type = DamageType.Type.SLASHING

    # Sharpened should be applicable to slashing weapons
    assert_true(sharpened.can_apply_to_weapon(sword), "Sharpened should apply to slashing weapons")

    return true
