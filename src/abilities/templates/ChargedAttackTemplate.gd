class_name ChargedAttackTemplate extends AbilityTemplate
## Template for generating charged attack abilities based on user's level and element affinity

class ElementInfo:
    var name: String
    var player_preparation_text: String
    var enemy_preparation_text: String
    var action_player: String
    var action_enemy: String
    var damage_type: DamageType.Type
    func set_name(new_name: String) -> ElementInfo:
        name = new_name
        return self
    func set_player_preparation_text(text: String) -> ElementInfo:
        player_preparation_text = text
        return self
    func set_enemy_preparation_text(text: String) -> ElementInfo:
        enemy_preparation_text = text
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
        .set_name("Inferno")
        .set_player_preparation_text("begin to heat up...")
        .set_enemy_preparation_text("begins to heat up...")
        .set_actions("unleash an inferno", "unleashes an inferno")
        .set_damage_type(DamageType.Type.FIRE),
    EnemyTemplate.ElementAffinity.ICE: ElementInfo.new()
        .set_name("Glacial Storm")
        .set_player_preparation_text("draw in an icy breath...")
        .set_enemy_preparation_text("draws in an icy breath...")
        .set_actions("unleash a glacial storm", "unleashes a glacial storm")
        .set_damage_type(DamageType.Type.ICE),
    EnemyTemplate.ElementAffinity.SHOCK: ElementInfo.new()
        .set_name("Thunder Bolt")
        .set_player_preparation_text("summon crackling energy...")
        .set_enemy_preparation_text("summons crackling energy...")
        .set_actions("unleash a bolt of thunder", "unleashes a bolt of thunder")
        .set_damage_type(DamageType.Type.SHOCK),
    EnemyTemplate.ElementAffinity.POISON: ElementInfo.new()
        .set_name("Poison Strike")
        .set_player_preparation_text("glare with venomous intent...")
        .set_enemy_preparation_text("glares with venomous intent...")
        .set_actions("unleash a toxic strike", "unleashes a toxic strike")
        .set_damage_type(DamageType.Type.POISON),
    EnemyTemplate.ElementAffinity.HOLY: ElementInfo.new()
        .set_name("Divine Bolt")
        .set_player_preparation_text("gathers holy light...")
        .set_enemy_preparation_text("gathers holy light...")
        .set_actions("unleash a divine bolt", "unleashes a divine bolt")
        .set_damage_type(DamageType.Type.HOLY),
    EnemyTemplate.ElementAffinity.DARK: ElementInfo.new()
        .set_name("Void Bolt")
        .set_player_preparation_text("channel dark energy...")
        .set_enemy_preparation_text("channels dark energy...")
        .set_actions("unleash a bolt of darkness", "unleashes a bolt of darkness")
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

    var ability := PreparationAbility.new()
    ability.ability_name = element_info.name
    ability.player_preparation_text = element_info.player_preparation_text
    ability.enemy_preparation_text = element_info.enemy_preparation_text
    ability.description = "Charges up to unleash a powerful %s attack." % element_info.name
    ability.priority = 14  # High priority for powerful abilities
    ability.cooldown = 3  # Longer cooldown due to power

    var attack := AttackAbility.new()
    attack.ability_name = element_info.name
    attack.base_damage = 10 + (effective_level * 3)  # Scales with level
    attack.damage_variance = 5 + effective_level  # Scales with level
    attack.override_damage_type = true
    attack.damage_type = element_info.damage_type
    attack.log_action_player = element_info.action_player
    attack.log_action_enemy = element_info.action_enemy

    ability.prepared_ability = attack

    return ability

## Helper: Get element info for display
func _get_element_info(affinity: EnemyTemplate.ElementAffinity) -> ElementInfo:
    if ELEMENT_MAPPING.has(affinity):
        return ELEMENT_MAPPING[affinity]
    else:
        return ELEMENT_MAPPING[EnemyTemplate.ElementAffinity.FIRE]
