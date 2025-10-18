# StageManager.gd
extends Node

## Manages stage progression and boss floor detection
## Stages are groups of floors with a boss at the end

signal stage_changed(new_stage: int)
signal boss_floor_reached(stage: int)
signal stage_completed(stage: int)

# Configuration
const DEFAULT_FLOORS_PER_STAGE: int = 10
var floors_per_stage: int = DEFAULT_FLOORS_PER_STAGE

# State tracking
var current_stage: int = 1
var floors_completed_in_current_stage: int = 0

func _ready() -> void:
	print("StageManager initialized")

## Get the current stage number (1-based)
func get_current_stage() -> int:
	return current_stage

## Get how many floors have been completed in the current stage (0-based)
func get_floors_completed_in_current_stage() -> int:
	return floors_completed_in_current_stage

## Get how many floors remain in the current stage before the boss
func get_floors_remaining_in_stage() -> int:
	return floors_per_stage - floors_completed_in_current_stage - 1  # -1 for boss floor

## Check if the current floor should be a boss floor
func is_boss_floor() -> bool:
	return floors_completed_in_current_stage == floors_per_stage - 1

## Check if we're in the early part of a stage (first 30%)
func is_early_stage() -> bool:
	var progress := get_stage_progress()
	return progress < 0.3

## Check if we're in the middle part of a stage (30%-70%)
func is_mid_stage() -> bool:
	var progress := get_stage_progress()
	return progress >= 0.3 and progress < 0.7

## Check if we're in the late part of a stage (70%+, excluding boss)
func is_late_stage() -> bool:
	var progress := get_stage_progress()
	return progress >= 0.7 and not is_boss_floor()

## Get progress through current stage as a float (0.0 to 1.0)
func get_stage_progress() -> float:
	if floors_per_stage <= 1:
		return 1.0
	return float(floors_completed_in_current_stage) / float(floors_per_stage)

## Advance to the next floor within the current stage
func advance_floor() -> void:
	floors_completed_in_current_stage += 1

	print("Stage %d: Floor %d/%d completed" % [current_stage, floors_completed_in_current_stage, floors_per_stage])

	# Check if this was the boss floor (stage completion)
	if floors_completed_in_current_stage >= floors_per_stage:
		complete_stage()
	elif is_boss_floor():
		boss_floor_reached.emit(current_stage)

## Complete the current stage and advance to the next
func complete_stage() -> void:
	print("Stage %d completed!" % current_stage)
	stage_completed.emit(current_stage)

	# Advance to next stage
	current_stage += 1
	floors_completed_in_current_stage = 0

	print("Advanced to Stage %d" % current_stage)
	stage_changed.emit(current_stage)

## Reset to the beginning (for new runs)
func reset() -> void:
	print("StageManager reset")
	current_stage = 1
	floors_completed_in_current_stage = 0

## Set custom floors per stage (useful for testing or configuration)
func set_floors_per_stage(floors: int) -> void:
	if floors < 1:
		push_error("Floors per stage must be at least 1")
		return

	floors_per_stage = floors
	print("Floors per stage set to: %d" % floors_per_stage)

## Get save data for persistence
func get_save_data() -> Dictionary:
	return {
		"current_stage": current_stage,
		"floors_completed_in_current_stage": floors_completed_in_current_stage,
		"floors_per_stage": floors_per_stage
	}

## Load save data
func load_save_data(data: Dictionary) -> void:
	current_stage = data.get("current_stage", 1)
	floors_completed_in_current_stage = data.get("floors_completed_in_current_stage", 0)
	floors_per_stage = data.get("floors_per_stage", DEFAULT_FLOORS_PER_STAGE)

	print("StageManager loaded: Stage %d, Floor %d/%d" % [current_stage, floors_completed_in_current_stage + 1, floors_per_stage])

## Get debug info string
func get_debug_info() -> String:
	var boss_indicator := " (BOSS)" if is_boss_floor() else ""
	var stage_type := ""

	if is_early_stage():
		stage_type = " [Early]"
	elif is_mid_stage():
		stage_type = " [Mid]"
	elif is_late_stage():
		stage_type = " [Late]"

	return "Stage %d: Floor %d/%d%s%s (%.1f%% progress)" % [
		current_stage,
		floors_completed_in_current_stage + 1,
		floors_per_stage,
		boss_indicator,
		stage_type,
		get_stage_progress() * 100
	]