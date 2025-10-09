class_name AttackAbility extends Ability

@export var base_damage: int = 0
@export var damage_variance: int = 3  # Random variance in damage
@export var status_effect: StatusEffect = null  # Optional status effect to apply
@export var effect_chance: float = 1.0  # Chance to apply status effect if present


func _init() -> void:
    ability_name = "Attack"
    description = "A basic attack ability."
    priority = 10

func execute(caster: CombatEntity, target: CombatEntity) -> void:
    if target == null:
        push_error("AttackAbility requires a target")
        return

    var damage := calculate_damage(caster)

    # Apply damage reduction if target is defending
    var final_damage := target.calculate_incoming_damage(damage)
    target.take_damage(final_damage)

    # Log the attack with proper context
    if status_effect != null:
        LogManager.log_special_attack(caster, target, ability_name, final_damage)
    else:
        LogManager.log_attack(caster, target, final_damage)

    # Apply status effect if present and chance succeeds
    if status_effect != null and randf() < effect_chance:
        var effect_copy: StatusEffect = status_effect.duplicate()
        target.apply_status_effect(effect_copy)




func calculate_damage(caster: CombatEntity) -> int:
    var damage := base_damage

    # Add caster's attack stat if available
    if caster.has_method("get_attack"):
        damage += caster.call("get_attack")

    # Add variance
    if damage_variance > 0:
        damage += randi() % damage_variance

    return max(damage, 1)  # Minimum 1 damage

func get_ability_type() -> Ability.AbilityType:
    return Ability.AbilityType.ATTACK

func can_use(caster: CombatEntity) -> bool:
    # Attack abilities can generally always be used
    return caster != null and caster.has_method("is_alive") and caster.is_alive()
