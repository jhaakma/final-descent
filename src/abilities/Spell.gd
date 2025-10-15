class_name Spell extends Resource

enum SpellTarget {
    SELF,    # Apply effects to the caster
    TARGET,  # Apply effects to the target
    BOTH     # Apply effects to both caster and target
}

@export var spell_name: String = "Spell"
@export var description: String = "A magical spell."
@export var spell_effects: Array[StatusEffect] = []
@export var target_type: SpellTarget = SpellTarget.TARGET
@export var mana_cost: int = 0

func cast(caster: CombatEntity, target: CombatEntity = null) -> void:
    if not caster:
        push_error("Spell.cast(): No caster provided")
        return

    # Log spell casting
    LogManager.log_combat("%s casts %s!" % [caster.get_name(), spell_name])

    # Apply effects based on target type
    match target_type:
        SpellTarget.SELF:
            _apply_spell_effects(caster)
        SpellTarget.TARGET:
            if target:
                _apply_spell_effects(target)
            else:
                push_error("Spell.cast(): No target provided for TARGET spell")
        SpellTarget.BOTH:
            _apply_spell_effects(caster)
            if target:
                _apply_spell_effects(target)

func _apply_spell_effects(entity: CombatEntity) -> void:
    for effect: StatusEffect in spell_effects:
        if not effect:
            continue

        # Create a status condition for the effect
        var condition := StatusCondition.new()
        condition.name = spell_name  # Use spell name for logging context
        condition.status_effect = effect.duplicate()
        condition.log_ability_name = true  # Log spell name instead of effect name

        # Apply the condition to the entity
        var _success := entity.apply_status_condition(condition)

func get_description() -> String:
    var desc := description
    if spell_effects.size() > 0:
        desc += "\nEffects: "
        var effect_names: Array[String] = []
        for effect: StatusEffect in spell_effects:
            if effect:
                effect_names.append(effect.get_effect_name())
        desc += ", ".join(effect_names)

    if mana_cost > 0:
        desc += "\nMana Cost: %d" % mana_cost

    return desc



func can_cast(_caster: CombatEntity) -> bool:
    return true

func get_target_type() -> SpellTarget:
    return target_type

func get_mana_cost() -> int:
    return mana_cost
