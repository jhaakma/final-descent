# GameState.gd
extends Node

signal stats_changed
signal inventory_changed
signal run_ended(victory: bool)
signal death_fade_start  # Forwarded from player when death fade should start

var current_floor: int = 1
var player: Player
var rng: RandomNumberGenerator
var ui_manager: UIManager

# Combat state tracking
var is_in_combat: bool = false
var current_enemy: Enemy = null

func _ready() -> void:
    rng = RandomNumberGenerator.new()
    rng.randomize()

    # Initialize UI Manager
    ui_manager = UIManager.new()
    add_child(ui_manager)

    # Initialize player
    player = Player.new()
    # Connect player signals to forward them
    player.stats_changed.connect(func() -> void: emit_signal("stats_changed"))
    player.inventory_changed.connect(func() -> void: emit_signal("inventory_changed"))
    # Connect death signals
    player.death_fade_start.connect(func() -> void: emit_signal("death_fade_start"))
    player.death_with_delay.connect(func() -> void: emit_signal("run_ended", false))

func reset_run() -> void:
    current_floor = 1
    player.reset()
    # Clear log history when starting a new run
    LogManager.clear_log_history()

func next_floor() -> void:
    current_floor += 1

    # Process status effects and apply their effects
    player.process_status_effects()

    # Death from status effects is now handled by Player.take_damage signal
    emit_signal("stats_changed")

# Combat state management
func start_combat(enemy: Enemy) -> void:
    is_in_combat = true
    current_enemy = enemy

func end_combat() -> void:
    is_in_combat = false
    current_enemy = null

func get_current_enemy() -> Enemy:
    return current_enemy
