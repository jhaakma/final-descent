class_name InstantHealEffect extends StatusEffect

@export var heal_amount: int = 5

func _init(healing: int = 5):
    super._init("Instant Heal")  # 0 turns for instant effect
    heal_amount = healing
    effect_color = EffectColor.POSITIVE

# Override apply_effect to implement instant healing logic
func apply_effect(target) -> StatusEffectResult:
    # Apply healing to target
    target.heal(heal_amount)

    # Log the healing effect
    LogManager.log_healing("Healed %d HP instantly!" % heal_amount)

    return StatusEffectResult.new(
        effect_name,
        "Healed %d HP instantly!" % heal_amount
    )

# Override get_description for instant heal formatting
func get_description() -> String:
    return "Instant Heal (%d HP)" % heal_amount