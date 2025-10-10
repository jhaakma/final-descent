# scenes/Main.gd
extends Node

@onready var screen_layer: CanvasLayer = %ScreenLayer
@onready var fade_overlay: ColorRect = %FadeOverlay

func _ready() -> void:
    # Connect to death fade signal
    GameState.death_fade_start.connect(_start_death_fade)
    show_title()

func _start_death_fade() -> void:
    # Create dramatic fade to red effect
    fade_overlay.visible = true
    fade_overlay.color = Color(1.0, 0.0, 0.0, 0.0)  # Transparent red

    # Create tween for smooth fade with dramatic timing
    var tween = create_tween()
    # First phase: Quick fade to subtle red
    # Second phase: Slower fade to more intense red
    tween.tween_property(fade_overlay, "color:a", 0.7, 1.0)
    # Optional: Fade back out
    tween.tween_property(fade_overlay, "color:a", 0.0, 1.0)

func show_title() -> void:
    _clear_layer()
    _reset_fade_overlay()
    var s: TitleScreen = load("res://data/ui/screens/TitleScreen.tscn").instantiate()
    screen_layer.add_child(s)
    s.start_requested.connect(_on_start_requested)

func _on_start_requested() -> void:
    GameState.reset_run()
    show_room()

func show_room() -> void:
    _clear_layer()
    var s: RoomScreen = load("res://data/ui/screens/RoomScreen.tscn").instantiate()
    screen_layer.add_child(s)
    s.room_cleared.connect(_on_room_cleared)
    s.run_ended.connect(_on_run_ended)

func _on_room_cleared() -> void:
    GameState.next_floor()
    show_room()

func _on_run_ended(victory: bool) -> void:
    if victory:
        show_title()  # Victory goes back to title for now
    else:
        show_game_over()  # Defeat shows game over screen

func show_game_over() -> void:
    _clear_layer()
    var s: GameOverScreen = load("res://data/ui/screens/GameOverScreen.tscn").instantiate()
    screen_layer.add_child(s)
    s.restart_requested.connect(_on_restart_requested)
    s.return_to_title_requested.connect(_on_return_to_title_requested)

func _on_restart_requested() -> void:
    GameState.reset_run()
    show_room()

func _on_return_to_title_requested() -> void:
    show_title()

func _clear_layer() -> void:
    for c in screen_layer.get_children():
        c.queue_free()

func _reset_fade_overlay() -> void:
    fade_overlay.visible = false
    fade_overlay.color = Color(1.0, 0.0, 0.0, 0.0)
