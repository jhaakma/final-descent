# CombatEntity.gd
# Abstract base class for entities that can participate in combat
class_name CombatEntity extends RefCounted

# Abstract method to be implemented by subclasses to provide entity name
func get_name() -> String:
    assert(false, "get_name() must be implemented by subclass")
    return ""

# Abstract method to be implemented by subclasses to provide attack damage type
func get_attack_damage_type() -> DamageType.Type:
    return DamageType.Type.PHYSICAL  # Default to physical damage

# Core combat components - shared by all combat entities
var stats_component: StatsComponent
var combat_actor: CombatActor
var status_effect_component: StatusEffectComponent
var resistance_component: ResistanceComponent

# Turn control - for effects like stun
var skip_next_turn: bool = false

# Base constructor for combat entities - must be called by subclasses
func _init_combat_entity(max_health: int, attack_power: int, defense: int) -> void:
    stats_component = StatsComponent.new(max_health, attack_power, defense)
    combat_actor = CombatActor.new(self)
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

# === COMBAT STATE MANAGEMENT ===
func set_defending(value: bool) -> void:
    if value:
        combat_actor.start_defending()
    else:
        combat_actor.stop_defending()

func get_is_defending() -> bool:
    return combat_actor.get_is_defending()

# Calculate damage taken considering defense state and damage type resistance
func calculate_incoming_damage(base_damage: int, damage_type: DamageType.Type = DamageType.Type.PHYSICAL) -> int:
    # First apply standard defense calculation
    var damage_after_defense := combat_actor.calculate_incoming_damage(base_damage)
    # Then apply damage type resistance
    return resistance_component.apply_resistance(damage_after_defense, damage_type)

# === STATUS EFFECT MANAGEMENT ===
func apply_status_effect(effect: StatusEffect) -> bool:
    return status_effect_component.apply_status_effect(effect, self)

func apply_status_condition(condition: StatusCondition) -> bool:
    return status_effect_component.apply_status_condition(condition, self)

func has_status_effect(effect_id: String) -> bool:
    return status_effect_component.has_effect(effect_id)

func has_status_condition(condition_name: String) -> bool:
    return status_effect_component.has_condition(condition_name)

func process_status_effects() -> void:
    status_effect_component.process_turn(self)

func clear_all_negative_status_effects() -> Array[StatusCondition]:
    return status_effect_component.clear_all_negative_status_effects()

func remove_status_effect(effect: StatusEffect) -> void:
    status_effect_component.remove_effect(effect)

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
