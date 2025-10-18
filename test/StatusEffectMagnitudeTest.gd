class_name StatusEffectMagnitudeTest extends BaseTest

func test_instant_damage_effect_magnitude() -> bool:
    var effect: InstantDamageEffect = InstantDamageEffect.new()
    effect.damage_amount = 10
    assert_equals(effect.get_magnitude(), 10, "InstantDamageEffect should return damage_amount as magnitude")
    return true

func test_instant_heal_effect_magnitude() -> bool:
    var effect: InstantHealEffect = InstantHealEffect.new()
    effect.heal_amount = 8
    assert_equals(effect.get_magnitude(), 8, "InstantHealEffect should return heal_amount as magnitude")
    return true

func test_repair_effect_magnitude() -> bool:
    var effect: RepairEffect = RepairEffect.new()
    effect.repair_amount = 5
    assert_equals(effect.get_magnitude(), 5, "RepairEffect should return repair_amount as magnitude")
    return true

func test_cure_status_effect_magnitude() -> bool:
    var effect: CureStatusEffect = CureStatusEffect.new()
    assert_equals(effect.get_magnitude(), 1, "CureStatusEffect should return 1 as magnitude")
    return true

func test_elemental_timed_effect_magnitude() -> bool:
    var effect: ElementalTimedEffect = ElementalTimedEffect.new()
    effect.damage_per_turn = 3
    assert_equals(effect.get_magnitude(), 3, "ElementalTimedEffect should return damage_per_turn as magnitude")
    return true

func test_regeneration_effect_magnitude() -> bool:
    var effect: RegenerationEffect = RegenerationEffect.new()
    effect.healing_per_turn = 4
    assert_equals(effect.get_magnitude(), 4, "RegenerationEffect should return healing_per_turn as magnitude")
    return true

func test_timed_effect_magnitude() -> bool:
    var effect: TimedEffect = TimedEffect.new()
    effect.duration = 5
    assert_equals(effect.get_magnitude(), 5, "TimedEffect should return duration as magnitude")
    return true

func test_strength_boost_effect_magnitude() -> bool:
    var effect: StrengthBoostEffect = StrengthBoostEffect.new()
    effect.strength_bonus = 3
    assert_equals(effect.get_magnitude(), 3, "StrengthBoostEffect should return strength_bonus as magnitude")
    return true

func test_defense_boost_effect_magnitude() -> bool:
    var effect: DefenseBoostEffect = DefenseBoostEffect.new()
    effect.defense_bonus = 2
    assert_equals(effect.get_magnitude(), 2, "DefenseBoostEffect should return defense_bonus as magnitude")
    return true

func test_vitality_boost_effect_magnitude() -> bool:
    var effect: VitalityBoostEffect = VitalityBoostEffect.new()
    effect.max_hp_bonus = 5
    assert_equals(effect.get_magnitude(), 5, "VitalityBoostEffect should return max_hp_bonus as magnitude")
    return true

func test_defend_effect_magnitude() -> bool:
    var effect: DefendEffect = DefendEffect.new()
    effect.defense_bonus = 50
    assert_equals(effect.get_magnitude(), 50, "DefendEffect should return defense_bonus as magnitude")
    return true

func test_balanced_boost_effect_magnitude() -> bool:
    var effect: BalancedBoostEffect = BalancedBoostEffect.new()
    effect.attack_bonus = 2
    effect.defense_bonus = 1
    assert_equals(effect.get_magnitude(), 2, "BalancedBoostEffect should return attack_bonus as magnitude")
    return true

func test_elemental_resistance_effect_magnitude() -> bool:
    var effect: ElementalResistanceEffect = ElementalResistanceEffect.new()
    assert_equals(effect.get_magnitude(), 1, "ElementalResistanceEffect should return 1 as magnitude")
    return true

func test_base_status_effect_magnitude_not_implemented() -> bool:
    var effect: StatusEffect = StatusEffect.new()
    # Should return 0 for base class (not implemented)
    assert_equals(effect.get_magnitude(), 0, "Base StatusEffect should return 0 when not implemented")
    return true