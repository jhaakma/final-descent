class_name ResetHighScoreOption extends Option

func get_display_name() -> String:
    return "Reset High Score"

func get_confirmation_message() -> String:
    var stats := _get_high_score_info()
    var message := "Are you sure you want to reset your high scores?\n\n"
    message += "Current Records:\n"
    message += "Best Floor: %d\n" % stats.best_floor
    message += "Best Gold: %d\n" % stats.best_gold
    message += "Total Runs: %d\n\n" % stats.total_runs
    message += "This action cannot be undone!"
    return message

func get_executed_message() -> String:
    return "High scores have been reset!"

func execute() -> void:
    StatsManager.reset_all_stats()

func _get_high_score_info() -> Dictionary:
    var stats := StatsManager.get_stats()
    return {
        "best_floor": stats.best_floor_reached,
        "best_gold": stats.best_gold_earned,
        "total_runs": stats.total_runs
    }
