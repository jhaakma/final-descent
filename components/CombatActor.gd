class_name CombatActor extends RefCounted

# Combat component that handles combat state and calculations for both Player and Enemy

# Combat state
var is_defending: bool = false
var defense_multiplier: float = 0.5  # Configurable defense multiplier

# Parent reference
var owner_actor: CombatEntity = null

func _init(actor: CombatEntity = null) -> void:
    owner_actor = actor

# === DAMAGE CALCULATION ===
func calculate_incoming_damage(base_damage: int) -> int:
    var final_damage := base_damage

    # Apply defending reduction using configurable multiplier
    if is_defending:
        final_damage = int(base_damage * defense_multiplier)
        is_defending = false  # Defense is consumed
        defense_multiplier = 0.5  # Reset to default for next use

    return final_damage

# === DEFENDING SYSTEM ===
func can_defend() -> bool:
    return not is_defending

func start_defending() -> void:
    is_defending = true

func stop_defending() -> void:
    is_defending = false

func get_is_defending() -> bool:
    return is_defending

func set_defense_multiplier(multiplier: float) -> void:
    defense_multiplier = multiplier

# === COMBAT ACTIONS ===
func apply_defend_action() -> void:
    # Unified defend action for all actors
    start_defending()

func remove_defend_effects() -> void:
    # No longer needed with unified system, but kept for compatibility
    pass

# === UTILITY ===
func reset_combat_state() -> void:
    is_defending = false
    defense_multiplier = 0.5  # Reset to default