class_name StrengthBlessingTemplate extends StatusConditionTemplate
## Template for generating strength blessing status conditions that scale with level

@export var base_attack_bonus: int = 3
@export var attack_bonus_per_level: float = 0.5
@export var base_duration: int = 10
@export var duration_per_level: float = 1.0

func generate_condition(user: CombatEntity) -> StatusCondition:
    var effective_level: int = 1

    if user and user.has_method("get_level"):
        effective_level = user.get_level()

    var attack_bonus: int = base_attack_bonus + int(attack_bonus_per_level * effective_level)
    var duration: int = base_duration + int(duration_per_level * effective_level)

    var effect := AttackBoostEffect.new()
    effect.attack_bonus = attack_bonus
    effect.expire_after_turns = duration
    effect.log_effect = true

    var condition := StatusCondition.new()
    condition.name = "Blessing of Strength"
    condition.status_effect = effect
    condition.log_ability_name = true
    condition.source_type = StatusCondition.SourceType.CONSUMABLE

    return condition
