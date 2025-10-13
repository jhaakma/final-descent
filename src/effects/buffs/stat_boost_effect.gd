class_name StatBoostEffect extends TimedEffect

# Base class for stat-boosting effects
# Subclasses should override the get_*_bonus methods they provide

func get_effect_type() -> EffectType:
    return EffectType.POSITIVE

# Apply effect per turn (no-op for stat boosts, handled by entity)
func apply_effect(_target: CombatEntity) -> bool:
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

# Called when the effect is applied - register bonuses with StatsComponent
func on_applied(target: CombatEntity) -> void:
    var effect_id := get_effect_id()

    if get_attack_bonus() != 0:
        target.stats_component.add_attack_bonus(effect_id, get_attack_bonus())

    if get_defense_bonus() != 0:
        target.stats_component.add_defense_bonus(effect_id, get_defense_bonus())

    if get_max_hp_bonus() != 0:
        target.stats_component.add_health_bonus(effect_id, get_max_hp_bonus())

# Called when the effect expires or is removed - unregister bonuses from StatsComponent
func on_removed(target: CombatEntity) -> void:
    var effect_id := get_effect_id()

    if get_attack_bonus() != 0:
        target.stats_component.remove_attack_bonus(effect_id)

    if get_defense_bonus() != 0:
        target.stats_component.remove_defense_bonus(effect_id)

    if get_max_hp_bonus() != 0:
        target.stats_component.remove_health_bonus(effect_id)
