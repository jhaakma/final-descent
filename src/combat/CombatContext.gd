class_name CombatContext extends RefCounted
## Data container for combat state that gets passed between processors
## Follows dependency inversion - processors depend on this abstraction

signal context_changed()

var player: Player
var enemy: Enemy
var enemy_resource: EnemyResource

# Combat settings
var enemy_first: bool = false
var avoid_failure: bool = false

# Combat state tracking
var is_combat_active: bool = false
var turn_count: int = 0

func _init(p_player: Player, p_enemy: Enemy, p_enemy_resource: EnemyResource) -> void:
    player = p_player
    enemy = p_enemy
    enemy_resource = p_enemy_resource
    is_combat_active = true
    turn_count = 0

func set_enemy_first(value: bool) -> void:
    enemy_first = value

func set_avoid_failure(value: bool) -> void:
    avoid_failure = value

func increment_turn() -> void:
    turn_count += 1
    context_changed.emit()

func end_combat() -> void:
    is_combat_active = false
    context_changed.emit()

func is_player_alive() -> bool:
    return player.get_hp() > 0

func is_enemy_alive() -> bool:
    return enemy.is_alive()

func is_combat_over() -> bool:
    return not is_combat_active or not is_player_alive() or not is_enemy_alive()

func get_combat_winner() -> String:
    if not is_player_alive():
        return "enemy"
    elif not is_enemy_alive():
        return "player"
    else:
        return "none"