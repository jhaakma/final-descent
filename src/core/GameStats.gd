# GameStats.gd
class_name GameStats extends RefCounted

var best_floor_reached: int
var best_gold_earned: int
var total_runs: int

func _init(p_best_floor: int = 0, p_best_gold: int = 0, p_total_runs: int = 0) -> void:
    best_floor_reached = p_best_floor
    best_gold_earned = p_best_gold
    total_runs = p_total_runs

# Create from dictionary (useful for loading from save files)
static func from_dict(data: Dictionary) -> GameStats:
    return GameStats.new(
        data.get("best_floor_reached", 0),
        data.get("best_gold_earned", 0),
        data.get("total_runs", 0)
    )

# Convert to dictionary (useful for saving to files)
func to_dict() -> Dictionary:
    return {
        "best_floor_reached": best_floor_reached,
        "best_gold_earned": best_gold_earned,
        "total_runs": total_runs
    }

# String representation for debugging
func _to_string() -> String:
    return "GameStats(floor: %d, gold: %d, runs: %d)" % [best_floor_reached, best_gold_earned, total_runs]