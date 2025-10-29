class_name AttackAbility extends AbilityResource


@export var base_damage: int = 0
@export var damage_variance: int = 3  # Random variance in damage
@export var override_damage_type: bool = true  # Whether to override caster's damage type
@export var damage_type: DamageType.Type = DamageType.Type.BLUNT  # Damage type override
@export var status_effect: StatusEffect = null  # Optional status effect to apply
@export var effect_chance: float = 1.0  # Chance to apply status effect if present
@export var _cooldown: int = 0  # Turns required between uses

func _init() -> void:
    ability_name = "Attack"
    description = "A basic attack ability."
    priority = 10

func get_cooldown() -> int:
    return _cooldown

func execute(_instance: AbilityInstance, caster: CombatEntity, target: CombatEntity) -> void:
    if target == null:
        push_error("AttackAbility requires a target")
        return

    var damage := calculate_damage(caster)

    # Determine damage type - use override if set, otherwise caster's default
    var attack_damage_type: DamageType.Type
    if override_damage_type:
        attack_damage_type = damage_type
    else:
        attack_damage_type = caster.get_attack_damage_type()

    # Apply damage reduction considering defense and damage type resistance
    var final_damage := target.calculate_incoming_damage(damage, attack_damage_type)
    final_damage = target.take_damage(final_damage)

    # Log the attack with new pattern-based approach
    if status_effect != null:
        LogManager.log_event("{You} {action} %s for {damage:%d}!" % [ability_name, final_damage], {"target": caster, "damage_type": attack_damage_type, "action": ["use", "uses"]})
    else:
        LogManager.log_event("{You} {action} for {damage:%d}!" % [final_damage], {"target": caster, "damage_type": attack_damage_type, "action": ["attack", "attacks"]})

    # Apply status effect if present and chance succeeds
    if status_effect != null and randf() < effect_chance:
        var effect_copy: StatusEffect = status_effect.create()
        target.apply_status_effect(effect_copy)

    # Mark single-turn ability as completed immediately
    _instance.current_state = AbilityInstance.AbilityState.COMPLETED




func calculate_damage(caster: CombatEntity) -> int:
    var damage := base_damage

    # Add caster's total attack power (unified method)
    damage += caster.get_total_attack_power()

    # Add variance
    if damage_variance > 0:
        damage += randi() % damage_variance

    return max(damage, 1)  # Minimum 1 damage

func get_ability_type() -> AbilityResource.AbilityType:
    return AbilityResource.AbilityType.ATTACK

func can_use(caster: CombatEntity) -> bool:
    # Attack abilities can generally always be used
    return caster != null and caster.has_method("is_alive") and caster.is_alive()
