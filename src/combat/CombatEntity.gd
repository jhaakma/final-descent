# CombatEntity.gd
# Abstract base class for entities that can participate in combat
class_name CombatEntity extends RefCounted

# Abstract method to be implemented by subclasses to provide entity name
func get_name() -> String:
    assert(false, "get_name() must be implemented by subclass")
    return ""

# Abstract method to be implemented by subclasses to provide attack damage type
func get_attack_damage_type() -> DamageType.Type:
    return DamageType.Type.BLUNT  # Default to blunt damage

# Core combat components - shared by all combat entities
var stats_component: StatsComponent
var status_effect_component: StatusEffectComponent
var resistance_component: ResistanceComponent

# Turn control - for effects like stun
var skip_next_turn: bool = false

# Base constructor for combat entities - must be called by subclasses
func _init_combat_entity(max_health: int, attack_power: int, defense: int) -> void:
    stats_component = StatsComponent.new(max_health, attack_power, defense)
    status_effect_component = StatusEffectComponent.new(self)
    resistance_component = ResistanceComponent.new()

# === HEALTH MANAGEMENT ===
func get_max_hp() -> int:
    return stats_component.get_total_max_health()

func get_current_hp() -> int:
    return stats_component.current_health

func is_alive() -> bool:
    return stats_component.current_health > 0

## Take damage, returns actual damage taken after reductions
func take_damage(damage: int) -> int:
    return stats_component.take_damage(damage)

func heal(amount: int) -> int:
    return stats_component.heal(amount)

# === STAT MANAGEMENT ===
func get_total_attack_power() -> int:
    return stats_component.get_total_attack_power()

func get_total_defense() -> int:
    return stats_component.get_total_defense()

func get_base_attack_power() -> int:
    return stats_component.attack_power

func get_base_defense() -> int:
    return stats_component.defense

func get_attack_bonus() -> int:
    return get_total_attack_power() - get_base_attack_power()

func get_defense_bonus() -> int:
    return get_total_defense() - get_base_defense()

# Get the current effective defense percentage including defend bonus (for UI display)
func get_current_defense_percentage() -> int:
    # This is now just the total defense from the stats component
    # (which includes any status effect bonuses like defend effect)
    return get_total_defense()

# Get just the defend bonus percentage (for UI display)
func get_defend_bonus_percentage() -> int:
    # Check if we have an active defend effect
    if has_status_effect("defend"):
        var condition := status_effect_component.get_effect("defend")
        if condition and condition.status_effect is DefendEffect:
            var defend_effect := condition.status_effect as DefendEffect
            return defend_effect.get_defense_bonus()
    return 0

# Calculate damage taken considering defense state and damage type resistance
func calculate_incoming_damage(base_damage: int, damage_type: DamageType.Type = DamageType.Type.BLUNT) -> int:
    # Start with base damage
    var final_damage := base_damage

    # Apply defense as percentage reduction (includes any status effect bonuses)
    var total_defense_percentage := float(get_total_defense())

    # Cap defense at 95% to prevent complete immunity
    total_defense_percentage = min(total_defense_percentage, 95.0)

    # Apply percentage reduction
    if total_defense_percentage > 0:
        var reduction_factor := total_defense_percentage / 100.0
        final_damage = int(float(base_damage) * (1.0 - reduction_factor))

    # Ensure minimum 1 damage unless defense is very high
    final_damage = max(1, final_damage)

    # Then apply damage type resistance
    return resistance_component.apply_resistance(final_damage, damage_type)


# === STATUS EFFECT MANAGEMENT ===
func apply_status_effect(effect: StatusEffect) -> bool:
    return status_effect_component.apply_status_effect(effect, self)

func apply_status_condition(condition: StatusCondition) -> bool:
    return status_effect_component.apply_status_condition(condition, self)

func has_status_effect(effect_name: String) -> bool:
    return status_effect_component.has_condition(effect_name)

func has_status_condition(condition_name: String) -> bool:
    return status_effect_component.has_condition(condition_name)

func process_status_effects() -> void:
    status_effect_component.process_turn(self)

func process_status_effects_at_timing(timing: EffectTiming.Type, current_turn: int) -> void:
    status_effect_component.process_status_effects_at_timing(timing, current_turn, self)

func process_all_timed_effects() -> void:
    status_effect_component.process_all_timed_effects(self)

func clear_all_negative_status_effects() -> Array[StatusCondition]:
    return status_effect_component.clear_all_negative_status_effects()

func remove_status_effect(effect: StatusEffect) -> void:
    status_effect_component.remove_effect(effect)

func remove_equipment_stack(effect: StatusEffect) -> void:
    status_effect_component.remove_equipment_stack(effect)

func remove_status_condition(condition_name: String) -> bool:
    return status_effect_component.remove_condition(condition_name)

func clear_all_status_effects() -> void:
    status_effect_component.clear_all_effects()

# Get descriptions of all active status effects
func get_status_effects_description() -> String:
    return status_effect_component.get_effects_description()

# === RESISTANCE MANAGEMENT ===

func set_resistant_to(damage_type: DamageType.Type) -> void:
    resistance_component.set_resistant_to(damage_type)

func set_weak_to(damage_type: DamageType.Type) -> void:
    resistance_component.set_weak_to(damage_type)

func add_damage_resistance(damage_type: DamageType.Type) -> void:
    resistance_component.set_resistant_to(damage_type)

func remove_damage_resistance(damage_type: DamageType.Type) -> void:
    resistance_component.set_neutral_to(damage_type)

func is_resistant_to(damage_type: DamageType.Type) -> bool:
    return resistance_component.is_resistant_to(damage_type)

func is_weak_to(damage_type: DamageType.Type) -> bool:
    return resistance_component.is_weak_to(damage_type)

func get_resistance_multiplier(damage_type: DamageType.Type) -> float:
    return resistance_component.get_resistance_multiplier(damage_type)

func get_resistances() -> Array[DamageType.Type]:
    return resistance_component.get_resistances()

func get_weaknesses() -> Array[DamageType.Type]:
    return resistance_component.get_weaknesses()

# Get all active status conditions
func get_all_status_conditions() -> Array[StatusCondition]:
    return status_effect_component.get_all_conditions()

# === TURN MANAGEMENT ===
# Check if this entity should skip their next turn
func should_skip_turn() -> bool:
    # Check if entity has any active stun effect (any StunEffect instance)
    var has_stun_effect := _is_stunned()
    print("DEBUG: should_skip_turn() called - has stun effect: ", has_stun_effect)
    return has_stun_effect

# Helper method to check for any StunEffect instance regardless of name
func _is_stunned() -> bool:
    var all_conditions: Array[StatusCondition] = status_effect_component.get_all_conditions()
    for condition: StatusCondition in all_conditions:
        if condition.status_effect is StunEffect:
            print("DEBUG: Found StunEffect with name: ", condition.status_effect.get_effect_name())
            return true
    return false

# Set whether this entity should skip their next turn (kept for compatibility)
func set_skip_turn(skip: bool) -> void:
    skip_next_turn = skip

# Process turn start - handles turn skipping for stunned entities
func process_turn_start() -> bool:
    # Check if entity is stunned (has active stun effect)
    if has_status_effect("Stun"):
        return true  # Indicates turn should be skipped
    return false  # Normal turn processing
