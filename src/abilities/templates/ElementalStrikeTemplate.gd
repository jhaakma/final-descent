class_name ElementalStrikeTemplate extends AbilityTemplate
## Template for generating elemental strike abilities based on user's element affinity

class ElementInfo:
    var name: String
    var action_player: String
    var action_enemy: String
    var damage_type: DamageType.Type
    func set_name(new_name: String) -> ElementInfo:
        name = new_name
        return self
    func set_actions(player_action: String, enemy_action: String) -> ElementInfo:
        action_player = player_action
        action_enemy = enemy_action
        return self
    func set_damage_type(d_type: DamageType.Type) -> ElementInfo:
        damage_type = d_type
        return self

var ELEMENT_MAPPING: Dictionary[EnemyTemplate.ElementAffinity, ElementInfo] = {
    EnemyTemplate.ElementAffinity.FIRE: ElementInfo.new()
        .set_name("Fire")
        .set_actions("strike", "strikes")
        .set_damage_type(DamageType.Type.FIRE),
    EnemyTemplate.ElementAffinity.ICE: ElementInfo.new()
        .set_name("Ice")
        .set_actions("strike", "strikes")
        .set_damage_type(DamageType.Type.ICE),
    EnemyTemplate.ElementAffinity.SHOCK: ElementInfo.new()
        .set_name("Shock")
        .set_actions("strike", "strikes")
        .set_damage_type(DamageType.Type.SHOCK),
    EnemyTemplate.ElementAffinity.POISON: ElementInfo.new()
        .set_name("Poison")
        .set_actions("strike", "strikes")
        .set_damage_type(DamageType.Type.POISON),
    EnemyTemplate.ElementAffinity.HOLY: ElementInfo.new()
        .set_name("Holy")
        .set_actions("strike", "strikes")
        .set_damage_type(DamageType.Type.HOLY),
    EnemyTemplate.ElementAffinity.DARK: ElementInfo.new()
        .set_name("Dark")
        .set_actions("strike", "strikes")
        .set_damage_type(DamageType.Type.DARK)
}

func generate_ability(user: EnemyResource = null) -> AbilityResource:
    var effective_level := 1
    var effective_affinity := EnemyTemplate.ElementAffinity.FIRE

    if user:
        effective_level = user.get_level()
        effective_affinity = user.get_element_affinity()

    if effective_affinity == EnemyTemplate.ElementAffinity.NONE:
        effective_affinity = EnemyTemplate.ElementAffinity.FIRE

    var element_info := _get_element_info(effective_affinity)

    var ability := AttackAbility.new()
    ability.ability_name = "%s Strike" % element_info.name
    ability.description = "A strike infused with %s energy" % element_info.name.to_lower()
    ability.priority = 7
    ability.base_damage = 3 + effective_level
    ability.damage_variance = 2
    ability.damage_type = element_info.damage_type
    ability.log_action_player = element_info.action_player
    ability.log_action_enemy = element_info.action_enemy
    return ability

## Helper: Get element info for display and mechanics
func _get_element_info(affinity: EnemyTemplate.ElementAffinity) -> ElementInfo:
    if ELEMENT_MAPPING.has(affinity):
        return ELEMENT_MAPPING[affinity]
    else:
        return ELEMENT_MAPPING[EnemyTemplate.ElementAffinity.FIRE]
