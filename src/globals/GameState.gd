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

    # Connect stage progression signals
    StageProgressionManager.all_stages_completed.connect(_on_all_stages_completed)

func _on_all_stages_completed() -> void:
    """Called when all stages have been completed - trigger victory"""
    emit_signal("run_ended", true)

func reset_run() -> void:
    current_floor = 1
    player.reset()
    # Clear log history when starting a new run
    LogManager.clear_log_history()
    # Reset stage progression
    StageProgressionManager.reset()

func next_floor() -> void:
    current_floor += 1

    # Process all timed status effects when transitioning floors
    player.process_all_timed_effects()

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

# Save/Load system support
func get_save_data() -> Dictionary:
    var save_data := {
        "current_floor": current_floor,
        "player": player.call("get_save_data") if player and player.has_method("get_save_data") else {}
    }
    return save_data

func load_save_data(data: Dictionary) -> void:
    current_floor = data.get("current_floor", 1)

    # Load player data (if player has save/load support)
    if player and player.has_method("load_save_data") and data.has("player"):
        player.call("load_save_data", data.player)

    # Refresh UI
    emit_signal("stats_changed")
    emit_signal("inventory_changed")
