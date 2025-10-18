class_name StageManagerTest extends BaseTest

func test_initial_state() -> bool:
    # Save original state
    var original_stage := StageManager.get_current_stage()
    var original_floors := StageManager.get_floors_completed_in_current_stage()

    # Reset to known state
    StageManager.reset()

    var result := true
    if StageManager.get_current_stage() != 1:
        result = false

    if StageManager.get_floors_completed_in_current_stage() != 0:
        result = false

    if not StageManager.is_early_stage():
        result = false

    if StageManager.is_boss_floor():
        result = false

    # Restore original state
    StageManager.current_stage = original_stage
    StageManager.floors_completed_in_current_stage = original_floors

    return result

func test_stage_progression() -> bool:
    # Save original state
    var original_stage := StageManager.get_current_stage()
    var original_floors := StageManager.get_floors_completed_in_current_stage()
    var original_floors_per_stage := StageManager.floors_per_stage

    # Set up test state
    StageManager.reset()
    StageManager.set_floors_per_stage(3)  # Small stage for testing

    var result := true

    # Start: Stage 1, Floor 1 (0 completed)
    if StageManager.get_current_stage() != 1:
        result = false

    if StageManager.get_floors_completed_in_current_stage() != 0:
        result = false

    # Advance to Floor 2
    StageManager.advance_floor()
    if StageManager.get_floors_completed_in_current_stage() != 1:
        result = false

    # Advance to Floor 3 (boss floor)
    StageManager.advance_floor()
    if StageManager.get_floors_completed_in_current_stage() != 2:
        result = false

    if not StageManager.is_boss_floor():
        result = false

    # Complete boss floor (should advance to stage 2)
    StageManager.advance_floor()
    if StageManager.get_current_stage() != 2:
        result = false

    if StageManager.get_floors_completed_in_current_stage() != 0:
        result = false

    # Restore original state
    StageManager.current_stage = original_stage
    StageManager.floors_completed_in_current_stage = original_floors
    StageManager.floors_per_stage = original_floors_per_stage

    return result

func test_boss_floor_detection() -> bool:
    # Save original state
    var original_stage := StageManager.get_current_stage()
    var original_floors := StageManager.get_floors_completed_in_current_stage()
    var original_floors_per_stage := StageManager.floors_per_stage

    # Set up test state
    StageManager.reset()
    StageManager.set_floors_per_stage(5)

    var result := true

    # Floors 1-4 should not be boss floors
    for i in range(4):
        if StageManager.is_boss_floor():
            result = false
        StageManager.advance_floor()

    # Floor 5 should be boss floor
    if not StageManager.is_boss_floor():
        result = false

    # Restore original state
    StageManager.current_stage = original_stage
    StageManager.floors_completed_in_current_stage = original_floors
    StageManager.floors_per_stage = original_floors_per_stage

    return result