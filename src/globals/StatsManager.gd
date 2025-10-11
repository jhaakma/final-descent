# StatsManager.gd
extends Node

signal stats_updated(stats: GameStats)

const SAVE_FILE_PATH = "user://game_stats.save"

# Game statistics
var best_floor_reached: int = 0
var best_gold_earned: int = 0
var total_runs: int = 0

func _ready() -> void:
    load_stats()

# Record a completed run and update best stats
func record_run(floor_reached: int, gold_earned: int) -> RunAchievements:
    var new_floor_record := false
    var new_gold_record := false

    # Increment total runs
    total_runs += 1

    # Check for new records
    if floor_reached > best_floor_reached:
        best_floor_reached = floor_reached
        new_floor_record = true

    if gold_earned > best_gold_earned:
        best_gold_earned = gold_earned
        new_gold_record = true

    # Create achievements object
    var achievements := RunAchievements.new(
        new_floor_record,
        new_gold_record,
        new_floor_record and new_gold_record
    )

    # Save the updated stats
    save_stats()

    # Emit signal for UI updates
    var current_stats := get_stats()
    emit_signal("stats_updated", current_stats)

    return achievements

# Get current stats
func get_stats() -> GameStats:
    return GameStats.new(best_floor_reached, best_gold_earned, total_runs)

# Save stats to file
func save_stats() -> void:
    var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
    if file:
        var current_stats := GameStats.new(best_floor_reached, best_gold_earned, total_runs)
        var save_data := current_stats.to_dict()
        save_data["version"] = 1  # For future compatibility

        file.store_string(JSON.stringify(save_data))
        file.close()
        print("Game stats saved successfully")
    else:
        print("Error: Failed to save game stats")

# Load stats from file
func load_stats() -> void:
    if FileAccess.file_exists(SAVE_FILE_PATH):
        var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
        if file:
            var json_string := file.get_as_text()
            file.close()

            var json := JSON.new()
            var parse_result := json.parse(json_string)

            if parse_result == OK:
                var save_data := json.data as Dictionary
                var loaded_stats := GameStats.from_dict(save_data)
                best_floor_reached = loaded_stats.best_floor_reached
                best_gold_earned = loaded_stats.best_gold_earned
                total_runs = loaded_stats.total_runs
                print("Game stats loaded: %s" % loaded_stats)
            else:
                print("Error: Failed to parse save file, starting with fresh stats")
                _reset_stats()
        else:
            print("Error: Failed to open save file for reading")
            _reset_stats()
    else:
        print("No save file found, starting with fresh stats")
        _reset_stats()

# Reset stats to default values
func _reset_stats() -> void:
    best_floor_reached = 0
    best_gold_earned = 0
    total_runs = 0

# Debug function to manually reset stats
func reset_all_stats() -> void:
    _reset_stats()
    save_stats()
    var current_stats := get_stats()
    emit_signal("stats_updated", current_stats)
    print("All stats have been reset")

# Get individual stat values
func get_best_floor() -> int:
    return best_floor_reached

func get_best_gold() -> int:
    return best_gold_earned

func get_total_runs() -> int:
    return total_runs