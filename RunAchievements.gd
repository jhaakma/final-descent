# RunAchievements.gd
class_name RunAchievements extends RefCounted

var new_best_floor: bool
var new_best_gold: bool
var is_new_overall_best: bool

func _init(p_new_floor: bool = false, p_new_gold: bool = false, p_overall_best: bool = false) -> void:
    new_best_floor = p_new_floor
    new_best_gold = p_new_gold
    is_new_overall_best = p_overall_best

# Check if any achievement was earned
func has_any_achievement() -> bool:
    return new_best_floor or new_best_gold or is_new_overall_best

# Get achievement type for display purposes
func get_achievement_type() -> String:
    if is_new_overall_best:
        return "overall_best"
    elif new_best_floor:
        return "floor_record"
    elif new_best_gold:
        return "gold_record"
    else:
        return "none"

# String representation for debugging
func _to_string() -> String:
    return "RunAchievements(floor: %s, gold: %s, overall: %s)" % [new_best_floor, new_best_gold, is_new_overall_best]