class_name EnemyModifierBuilder extends RefCounted
## Builder pattern for creating enemy modifier data

var _data: EnemyModifierData

func _init() -> void:
    _data = EnemyModifierData.new()

static func create() -> EnemyModifierBuilder:
    return EnemyModifierBuilder.new()

func with_health_modifier(modifier: float) -> EnemyModifierBuilder:
    _data.health_modifier = modifier
    return self

func with_attack_modifier(modifier: float) -> EnemyModifierBuilder:
    _data.attack_modifier = modifier
    return self

func with_defense_modifier(modifier: float) -> EnemyModifierBuilder:
    _data.defense_modifier = modifier
    return self

func with_avoid_chance_modifier(modifier: float) -> EnemyModifierBuilder:
    _data.avoid_chance_modifier = modifier
    return self

func with_prefix(prefix: String) -> EnemyModifierBuilder:
    _data.name_prefix = prefix
    return self

func with_suffix(suffix: String) -> EnemyModifierBuilder:
    _data.name_suffix = suffix
    return self

func with_ability(ability: AbilityResource) -> EnemyModifierBuilder:
    if ability and not _data.additional_abilities.has(ability):
        _data.additional_abilities.append(ability)
    return self

func with_abilities(abilities: Array[AbilityResource]) -> EnemyModifierBuilder:
    for ability in abilities:
        if ability and not _data.additional_abilities.has(ability):
            _data.additional_abilities.append(ability)
    return self

func resist(damage_type: DamageType.Type) -> EnemyModifierBuilder:
    if not _data.additional_resistances.has(damage_type):
        _data.additional_resistances.append(damage_type)
    return self

func resists(damage_types: Array[DamageType.Type]) -> EnemyModifierBuilder:
    for damage_type in damage_types:
        if not _data.additional_resistances.has(damage_type):
            _data.additional_resistances.append(damage_type)
    return self

func weak_against(damage_type: DamageType.Type) -> EnemyModifierBuilder:
    if not _data.additional_weaknesses.has(damage_type):
        _data.additional_weaknesses.append(damage_type)
    return self

func weak_to(damage_types: Array[DamageType.Type]) -> EnemyModifierBuilder:
    for damage_type in damage_types:
        if not _data.additional_weaknesses.has(damage_type):
            _data.additional_weaknesses.append(damage_type)
    return self

func with_rarity_weight(weight: float) -> EnemyModifierBuilder:
    _data.rarity_weight = weight
    return self

func stackable() -> EnemyModifierBuilder:
    _data.can_stack = true
    return self

func non_stackable() -> EnemyModifierBuilder:
    _data.can_stack = false
    return self

# Convenience methods for common modifier patterns
func elite() -> EnemyModifierBuilder:
    return (with_prefix("Elite")
          .with_health_modifier(1.5)
          .with_attack_modifier(1.3)
          .with_defense_modifier(1.2)
          .with_rarity_weight(0.1))

func champion() -> EnemyModifierBuilder:
    return( with_prefix("Champion")
          .with_health_modifier(2.0)
          .with_attack_modifier(1.5)
          .with_defense_modifier(1.5)
          .with_rarity_weight(0.05))

func ancient() -> EnemyModifierBuilder:
    return (with_prefix("Ancient")
          .with_health_modifier(1.8)
          .with_attack_modifier(1.4)
          .with_defense_modifier(1.3)
          .with_rarity_weight(0.08))

func young() -> EnemyModifierBuilder:
    return (with_prefix("Young")
          .with_health_modifier(0.7)
          .with_attack_modifier(0.8)
          .with_defense_modifier(0.8)
          .with_avoid_chance_modifier(0.2)
          .with_rarity_weight(1.5))

func armored() -> EnemyModifierBuilder:
    return (with_prefix("Armored")
          .with_health_modifier(1.0)
          .with_attack_modifier(1.0)
          .with_defense_modifier(1.5)
          .with_rarity_weight(0.8))

func berserker() -> EnemyModifierBuilder:
    return (with_prefix("Berserker")
          .with_health_modifier(1.2)
          .with_attack_modifier(1.8)
          .with_defense_modifier(0.7)
          .with_rarity_weight(0.6))

func swift() -> EnemyModifierBuilder:
    return (with_prefix("Swift")
          .with_health_modifier(0.8)
          .with_attack_modifier(1.1)
          .with_defense_modifier(1.0)
          .with_avoid_chance_modifier(0.3)
          .with_rarity_weight(1.0))

func giant() -> EnemyModifierBuilder:
    return (with_prefix("Giant")
          .with_health_modifier(2.0)
          .with_attack_modifier(1.3)
          .with_defense_modifier(1.1)
          .with_avoid_chance_modifier(-0.2)
          .with_rarity_weight(0.3))

func tiny() -> EnemyModifierBuilder:
    return (with_prefix("Tiny")
          .with_health_modifier(0.5)
          .with_attack_modifier(0.7)
          .with_defense_modifier(0.9)
          .with_avoid_chance_modifier(0.4)
          .with_rarity_weight(1.2))

func diseased() -> EnemyModifierBuilder:
    return (with_prefix("Diseased")
          .with_health_modifier(0.8)
          .with_attack_modifier(1.0)
          .with_defense_modifier(0.9)
          .resist(DamageType.Type.POISON)
          .with_rarity_weight(0.7))

func blessed() -> EnemyModifierBuilder:
    return (with_prefix("Blessed")
          .with_health_modifier(1.3)
          .with_attack_modifier(1.2)
          .with_defense_modifier(1.2)
          .resist(DamageType.Type.HOLY).weak_against(DamageType.Type.DARK)
          .with_rarity_weight(0.4))

func cursed() -> EnemyModifierBuilder:
    return (with_prefix("Cursed")
          .with_health_modifier(1.1)
          .with_attack_modifier(1.4)
          .with_defense_modifier(0.8)
          .resist(DamageType.Type.DARK).weak_against(DamageType.Type.HOLY)
          .with_rarity_weight(0.5))

func build() -> EnemyModifierData:
    return _data