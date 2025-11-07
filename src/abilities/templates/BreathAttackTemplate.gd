class_name BreathAttackTemplate extends AbilityTemplate
## Template for generating breath attack abilities based on user's element affinity

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
        .set_name("Fire Breath")
        .set_actions("breathe flame", "breathes flame")
        .set_damage_type(DamageType.Type.FIRE),
    EnemyTemplate.ElementAffinity.ICE: ElementInfo.new()
        .set_name("Frost Breath")
        .set_actions("breathe frost", "breathes frost")
        .set_damage_type(DamageType.Type.ICE),
    EnemyTemplate.ElementAffinity.SHOCK: ElementInfo.new()
        .set_name("Lightning Breath")
        .set_actions("spit lightning", "spits lightning")
        .set_damage_type(DamageType.Type.SHOCK),
    EnemyTemplate.ElementAffinity.POISON: ElementInfo.new()
        .set_name("Toxic Breath")
        .set_actions("exhale toxic fumes", "exhales toxic fumes")
        .set_damage_type(DamageType.Type.POISON),
    EnemyTemplate.ElementAffinity.HOLY: ElementInfo.new()
        .set_name("Holy Breath")
        .set_actions("breathe radiant light", "breathes radiant light")
        .set_damage_type(DamageType.Type.HOLY),
    EnemyTemplate.ElementAffinity.DARK: ElementInfo.new()
        .set_name("Void Breath")
        .set_actions("breathe a dark mist", "breathes a dark mist")
        .set_damage_type(DamageType.Type.DARK)
}



func generate_ability(user:EnemyResource = null) -> AbilityResource:
    var effective_level := 1
    var effective_affinity := EnemyTemplate.ElementAffinity.FIRE

    if user:
        effective_level = user.get_level()
        effective_affinity = user.get_element_affinity()

    if effective_affinity == EnemyTemplate.ElementAffinity.NONE:
        effective_affinity = EnemyTemplate.ElementAffinity.FIRE

    var element_info := _get_element_names(effective_affinity)

    var element_name: String = element_info.name
    var ability := AttackAbility.new()
    ability.ability_name = "%s Breath" % element_name
    ability.description = "Exhales a blast of %s energy" % element_name.to_lower()
    ability.priority = 6
    ability.base_damage = 5 + (effective_level * 2)
    ability.damage_variance = 3
    ability.damage_type = element_info.damage_type
    ability.log_action_player = element_info.action_player
    ability.log_action_enemy = element_info.action_enemy
    ability.cooldown = 3
    return ability


## Helper: Get element name for display
func _get_element_names(affinity: EnemyTemplate.ElementAffinity) -> ElementInfo:
    if ELEMENT_MAPPING.has(affinity):
        return ELEMENT_MAPPING[affinity]
    else:
        return ELEMENT_MAPPING[EnemyTemplate.ElementAffinity.FIRE]
