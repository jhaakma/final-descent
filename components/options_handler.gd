# components/OptionsHandler.gd
class_name OptionsHandler extends RefCounted

# Signal to notify when an option has been executed
signal option_executed(option_name: String, success: bool, message: String)

# Reset high score functionality
func reset_high_score() -> void:
    StatsManager.reset_all_stats()
    emit_signal("option_executed", "reset_high_score", true, "High scores have been reset successfully!")

# Get current high score stats for display
func get_high_score_info() -> Dictionary:
    var stats = StatsManager.get_stats()
    return {
        "best_floor": stats.best_floor_reached,
        "best_gold": stats.best_gold_earned,
        "total_runs": stats.total_runs
    }

# Future options can be added here following SRP
# Each option should be a separate method with a clear purpose