# enemies/Enemy.gd
class_name Enemy extends RefCounted

signal action_performed(action_type: String, value: int, message: String)

var resource: EnemyResource
var current_hp: int
var is_defending: bool = false
var flee_chance: float = 0.3  # Base flee chance
var planned_action: Callable  # Store the action planned at start of turn

# Status effects
var status_effect_manager: StatusEffectManager = StatusEffectManager.new()

func _init(enemy_resource: EnemyResource) -> void:
    resource = enemy_resource
    current_hp = resource.max_hp

func get_name() -> String:
    return resource.name

func get_max_hp() -> int:
    return resource.max_hp

func get_current_hp() -> int:
    return current_hp

func get_attack() -> int:
    return resource.attack

func is_alive() -> bool:
    return current_hp > 0

func take_damage(damage: int) -> int:
    var actual_damage = max(0, damage)
    current_hp = max(0, current_hp - actual_damage)
    return actual_damage

func heal(amount: int) -> int:
    var actual_heal = min(amount, resource.max_hp - current_hp)
    current_hp = min(resource.max_hp, current_hp + actual_heal)
    return actual_heal

# Enemy AI decision making - call this at the start of turn before damage
func plan_action() -> void:
    # Simple AI logic - can be expanded later
    var hp_percentage = float(current_hp) / float(resource.max_hp)

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
    var message = "%s attacks for %d damage!" % [resource.name, damage]
    action_performed.emit("attack", damage, message)

func _perform_special_attack(attack) -> void:
    var damage = attack.get_damage()

    if is_defending:
        damage = int(damage * 0.5)
        is_defending = false

    # Execute the attack and get the message
    var message = attack.execute_attack(resource.name, GameState.player)

    # Emit the attack signal with the damage
    action_performed.emit("attack", damage, message)

func _perform_defend() -> void:
    is_defending = true
    var message = "%s braces for defense!" % resource.name
    action_performed.emit("defend", 0, message)

func _attempt_flee() -> void:
    if randf() < flee_chance:
        var message = "%s attempts to flee!" % resource.name
        action_performed.emit("flee_success", 0, message)
    else:
        var message = "%s tries to flee but fails!" % resource.name
        action_performed.emit("flee_fail", 0, message)
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
    status_effect_manager.apply_effect(effect, self)

func has_status_effect(effect_name: String) -> bool:
    return status_effect_manager.has_effect(effect_name)

func process_status_effects() -> Array[StatusEffectResult]:
    return status_effect_manager.process_turn(self)

func get_status_effect_description(effect_name: String) -> String:
    var status_effect = status_effect_manager.get_effect(effect_name)
    if status_effect:
        return status_effect.get_description()
    return ""

func remove_status_effect(effect_name: String) -> void:
    status_effect_manager.remove_effect(effect_name)

func clear_all_status_effects() -> void:
    status_effect_manager.clear_all_effects()

# Get descriptions of all active status effects
func get_status_effects_description() -> String:
    return status_effect_manager.get_effects_description()

# Get all active status effects
func get_all_status_effects() -> Array[StatusEffect]:
    return status_effect_manager.get_all_effects()