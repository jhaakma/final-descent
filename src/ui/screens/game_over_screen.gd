# screens/GameOverScreen.gd
class_name GameOverScreen extends Control

signal restart_requested
signal return_to_title_requested

@onready var game_over_title: Label = %GameOverTitle
@onready var personal_best_title: Label = %PersonalBestTitle
@onready var final_floor_label: Label = %FinalFloorLabel
@onready var final_gold_label: Label = %FinalGoldLabel
@onready var best_floor_label: Label = %BestFloorLabel
@onready var best_gold_label: Label = %BestGoldLabel
@onready var total_runs_label: Label = %TotalRunsLabel
@onready var restart_btn: Button = %RestartBtn
@onready var title_btn: Button = %TitleBtn

var is_victory: bool = false

static func get_scene() -> PackedScene:
    return preload("uid://c7rm5at1hk0aj") as PackedScene

func initialize(victory: bool) -> void:
    """Initialize the screen with victory or defeat state"""
    is_victory = victory

func _ready() -> void:
    # Connect button signals
    restart_btn.pressed.connect(_on_restart_pressed)
    title_btn.pressed.connect(_on_title_pressed)

    # Record this run and get achievement info
    var achievements: RunAchievements = StatsManager.record_run(GameState.current_floor, GameState.player.gold)

    # Display stats
    _display_stats(achievements)

    # Update title based on victory/defeat
    if is_victory:
        game_over_title.text = "Victory!"
        game_over_title.modulate = Color(1, 0.84, 0)  # Gold color
    else:
        game_over_title.text = "Game Over"
        game_over_title.modulate = Color(1, 1, 1)  # White color

func _display_stats(achievements: RunAchievements) -> void:
    var stats: GameStats = StatsManager.get_stats()

    # Current run stats
    final_floor_label.text = "Floor Reached: %d" % GameState.current_floor
    final_gold_label.text = "Gold Earned: %d" % GameState.player.gold

    # Best stats
    best_floor_label.text = "Best Floor: %d" % stats.best_floor_reached
    best_gold_label.text = "Best Gold: %d" % stats.best_gold_earned
    total_runs_label.text = "Total Runs: %d" % stats.total_runs

    # Update title and highlights based on achievements
    if achievements.is_new_overall_best:
        personal_best_title.text = "New Personal Best!"
        final_floor_label.modulate = Color(1, 0.84, 0)  # Gold color
        final_gold_label.modulate = Color(1, 0.84, 0)
    elif achievements.new_best_floor:
        personal_best_title.text = "New Floor Record!"
        final_floor_label.modulate = Color(1, 0.84, 0)  # Gold color
    elif achievements.new_best_gold:
        personal_best_title.text = "New Gold Record!"
        final_gold_label.modulate = Color(1, 0.84, 0)
    else:
        personal_best_title.text = ""

func _on_restart_pressed() -> void:
    emit_signal("restart_requested")

func _on_title_pressed() -> void:
    emit_signal("return_to_title_requested")
