@tool
extends Item

var stun_effect: StunEffect

func _init() -> void:
    name = "Enemy Stun Test"
    description = "A test item that stuns the current enemy for 2 turns."
    purchase_value = 5

    # Create a stun effect that lasts 2 turns
    stun_effect = StunEffect.new(2)

func use() -> bool:
    if not can_use():
        return false

    # Get the current enemy from the combat popup if in combat
    var combat_popup = get_tree().get_first_node_in_group("combat_popup")
    if combat_popup and combat_popup.has_method("get_current_enemy"):
        var current_enemy = combat_popup.get_current_enemy()
        if current_enemy:
            # Apply stun effect to the enemy
            var effect_copy: StatusEffect = stun_effect.duplicate()
            current_enemy.apply_status_effect(effect_copy)
            LogManager.log_combat("You stun %s for 2 turns!" % current_enemy.get_name())
            return true

    LogManager.log_combat("No enemy to stun!")
    return false

func can_use() -> bool:
    # Can only use this item in combat
    return get_tree().get_first_node_in_group("combat_popup") != null
