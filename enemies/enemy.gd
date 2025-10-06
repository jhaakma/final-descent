# enemies/Enemy.gd
class_name Enemy extends RefCounted

signal action_performed(action_type: String, value: int, message: String)

var resource: EnemyResource
var health_component: HealthComponent
var is_defending: bool = false
var flee_chance: float = 0.3  # Base flee chance
var planned_action: Callable  # Store the action planned at start of turn

# Status effects
var status_effect_component: StatusEffectComponent = StatusEffectComponent.new()

func _init(enemy_resource: EnemyResource) -> void:
    resource = enemy_resource
    health_component = HealthComponent.new(resource.max_hp)

func get_name() -> String:
    return resource.name

func get_max_hp() -> int:
    return health_component.get_max_hp()

func get_current_hp() -> int:
    return health_component.get_current_hp()

func get_attack() -> int:
    return resource.attack

func is_alive() -> bool:
    return health_component.is_alive()

func take_damage(damage: int) -> int:
    return health_component.take_damage(damage)

func heal(amount: int) -> int:
    return health_component.heal(amount)

# Enemy AI decision making - call this at the start of turn before damage
func plan_action() -> void:
    # Simple AI logic - can be expanded later
    var hp_percentage = health_component.get_hp_percentage()

    # If health is low, consider fleeing or defending
    if hp_percentage <= 0.3:
        print("Enemy health low, considering flee or defend")
        var action_roll = randf()
        if action_roll < 0.4:
            planned_action = _attempt_flee
        elif action_roll < 0.7:
            planned_action = _perform_defend
        else:
            planned_action = _perform_attack
    # If health is moderate, sometimes defend
    elif hp_percentage <= 0.6:
        if randf() < 0.2:
            planned_action = _perform_defend
        else:
            planned_action = _perform_attack
    # If health is good, mostly attack
    else:
        if randf() < 0.1:
            planned_action = _perform_defend
        else:
            planned_action = _perform_attack

# Execute the action that was planned at the start of the turn
func perform_planned_action() -> void:
    if planned_action != null:
        planned_action.call()
    else:
        # Fallback to attack if no action was planned
        _perform_attack()

# Legacy method for backwards compatibility - now just plans and executes immediately
func perform_action() -> void:
    plan_action()
    perform_planned_action()

func _perform_attack() -> void:
    var special_attacks := resource.get_special_attacks()
    if special_attacks.size() > 0:
        var eligible_attacks = []
        for attack in special_attacks:
            if attack.can_use(self) and randf() < attack.use_chance:
                eligible_attacks.append(attack)
        if eligible_attacks.size() > 0:
            var chosen_attack = eligible_attacks[randi() % eligible_attacks.size()]
            _perform_special_attack(chosen_attack)
            return

    # Regular attack
    var base_damage = resource.attack
    if is_defending:
        base_damage = int(base_damage * 0.5)  # Defending reduces next attack
        is_defending = false

    var damage = base_damage + randi() % 3
    # Use enhanced logging with target context
    LogManager.log_attack(self, GameState.player, damage)
    action_performed.emit("attack", damage, "")

func _perform_special_attack(attack) -> void:
    var damage = attack.get_damage()

    if is_defending:
        damage = int(damage * 0.5)
        is_defending = false

    # Execute the attack with full attacker object for better logging
    attack.execute_attack(self, GameState.player)

    # Emit the attack signal (message is now handled by LogManager)
    action_performed.emit("attack", damage, "")

func _perform_defend() -> void:
    is_defending = true
    # Use enhanced logging with target context
    LogManager.log_defend(self)
    action_performed.emit("defend", 0, "")

func _attempt_flee() -> void:
    var success = randf() < flee_chance
    LogManager.log_flee_attempt(self, success)

    if success:
        action_performed.emit("flee_success", 0, "")
    else:
        action_performed.emit("flee_fail", 0, "")
        # Failed flee attempt still counts as an action, enemy is vulnerable
        _perform_attack()

# Calculate damage taken considering defense state
func calculate_incoming_damage(base_damage: int) -> int:
    var final_damage = base_damage
    if is_defending:
        print("Defending: Halving incoming damage")
        final_damage = int(base_damage * 0.5)  # Defending halves incoming damage
        is_defending = false  # Defense is consumed
    else:
        print("Not defending: Full damage taken")
    return final_damage

# === STATUS EFFECT MANAGEMENT ===
func apply_status_effect(effect: StatusEffect) -> void:
    status_effect_component.apply_effect(effect, self)

func has_status_effect(effect_name: String) -> bool:
    return status_effect_component.has_effect(effect_name)

func process_status_effects() -> Array[StatusEffectResult]:
    return status_effect_component.process_turn(self)

func get_status_effect_description(effect_name: String) -> String:
    var status_effect = status_effect_component.get_effect(effect_name)
    if status_effect:
        return status_effect.get_description()
    return ""

func remove_status_effect(effect_name: String) -> void:
    status_effect_component.remove_effect(effect_name)

func clear_all_status_effects() -> void:
    status_effect_component.clear_all_effects()

# Get descriptions of all active status effects
func get_status_effects_description() -> String:
    return status_effect_component.get_effects_description()

# Get all active status effects
func get_all_status_effects() -> Array[StatusEffect]:
    return status_effect_component.get_all_effects()
