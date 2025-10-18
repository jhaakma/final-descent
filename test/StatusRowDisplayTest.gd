class_name StatusRowDisplayTest extends BaseTest

func get_test_name() -> String:
	return "StatusRowDisplayTest"

# Test that status effects display proper descriptions with magnitude, unit and turns
func test_elemental_timed_effect_description() -> bool:
	var poison_effect: ElementalTimedEffect = ElementalTimedEffect.new()
	poison_effect.damage_per_turn = 2
	poison_effect.elemental_type = DamageType.Type.POISON
	poison_effect.duration = 3
	poison_effect.initialize()

	var expected: String = "2 damage for 3 turns"
	var actual: String = poison_effect.get_description()

	return assert_equals(expected, actual, "Poison effect should show '2 damage for 3 turns'")

# Test attack boost effect description
func test_attack_boost_description() -> bool:
	var attack_boost: AttackBoostEffect = AttackBoostEffect.new()
	attack_boost.attack_bonus = 2
	attack_boost.duration = 10
	attack_boost.initialize()

	var expected: String = "+2 ATK for 10 turns"
	var actual: String = attack_boost.get_description()

	return assert_equals(expected, actual, "Attack boost should show '+2 ATK for 10 turns'")

# Test regeneration effect description
func test_regeneration_description() -> bool:
	var regen_effect: RegenerationEffect = RegenerationEffect.new()
	regen_effect.healing_per_turn = 2
	regen_effect.duration = 5
	regen_effect.initialize()

	var expected: String = "+2 HP for 5 turns"
	var actual: String = regen_effect.get_description()

	return assert_equals(expected, actual, "Regeneration should show '+2 HP for 5 turns'")

# Test vitality boost effect description (blessing of vitality)
func test_vitality_boost_description() -> bool:
	var vitality_boost: VitalityBoostEffect = VitalityBoostEffect.new()
	vitality_boost.max_hp_bonus = 5  # Matches BlessingOfVitality.tres
	vitality_boost.duration = 10
	vitality_boost.initialize()

	var expected: String = "+5 MAX HP for 10 turns"
	var actual: String = vitality_boost.get_description()

	return assert_equals(expected, actual, "Blessing of Vitality should show '+5 MAX HP for 10 turns'")

# Test instant heal effect description (no turns)
func test_instant_heal_description() -> bool:
	var heal_effect: InstantHealEffect = InstantHealEffect.new()
	heal_effect.heal_amount = 5

	var expected: String = "+5 HP"
	var actual: String = heal_effect.get_description()

	return assert_equals(expected, actual, "Instant heal should show '+5 HP'")

# Test instant damage effect description (no turns)
func test_instant_damage_description() -> bool:
	var damage_effect: InstantDamageEffect = InstantDamageEffect.new()
	damage_effect.damage_amount = 3
	damage_effect.damage_type = DamageType.Type.FIRE

	var expected: String = "3 damage"
	var actual: String = damage_effect.get_description()

	return assert_equals(expected, actual, "Instant damage should show '3 damage'")

# Test stun effect description
func test_stun_effect_description() -> bool:
	var stun_effect: StunEffect = StunEffect.new()
	stun_effect.duration = 2
	stun_effect.initialize()

	var expected: String = "Stunned for 2 turns"
	var actual: String = stun_effect.get_description()

	return assert_equals(expected, actual, "Stun effect should show 'Stunned for 2 turns'")

# Test constant effect (no turns)
func test_strength_boost_constant_description() -> bool:
	var strength_boost: StrengthBoostEffect = StrengthBoostEffect.new()
	strength_boost.strength_bonus = 3

	var expected: String = "Strength +3"
	var actual: String = strength_boost.get_description()

	return assert_equals(expected, actual, "Strength boost should show 'Strength +3'")

# Test elemental resistance constant effect
func test_elemental_resistance_description() -> bool:
	var fire_resistance: ElementalResistanceEffect = ElementalResistanceEffect.new()
	fire_resistance.elemental_type = DamageType.Type.FIRE

	var expected: String = "Fire resistance"
	var actual: String = fire_resistance.get_description()

	return assert_equals(expected, actual, "Fire resistance should show 'Fire resistance'")