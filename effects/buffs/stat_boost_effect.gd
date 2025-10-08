class_name StatBoostEffect extends TimedEffect

# Base class for stat-boosting effects
# Subclasses should override the get_*_bonus methods they provide

func _init(name: String = "", turns: int = 1) -> void:
    super._init(name, turns)
    effect_type = EffectType.POSITIVE

# Apply effect per turn (no-op for stat boosts, handled by entity)
func apply_effect(_target:CombatEntity) -> bool:
    return true

# Override in subclasses that provide attack bonuses
func get_attack_bonus() -> int:
    return 0

# Override in subclasses that provide defense bonuses
func get_defense_bonus() -> int:
    return 0

# Override in subclasses that provide max HP bonuses
func get_max_hp_bonus() -> int:
    return 0