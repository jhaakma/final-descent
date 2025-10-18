# StageManager Documentation

## Overview
The StageManager is a singleton that manages stage progression and boss floor detection for the Final Descent roguelike dungeon crawler. It tracks the player's progress through stages, where each stage consists of a configurable number of floors with a boss at the end.

## Core Concepts

### Stages
- **Stage**: A group of floors (default: 10) with a boss at the end
- **Stage Number**: 1-based indexing (Stage 1, Stage 2, etc.)
- **Floor**: Individual rooms within a stage
- **Boss Floor**: The final floor of each stage with a powerful enemy

### Stage Progression
- Players start at Stage 1, Floor 1
- Each floor completion advances the floor counter
- When all floors in a stage are completed, the player advances to the next stage
- Stage difficulty is expected to increase (implementation pending)

## API Reference

### Properties
- `current_stage: int` - Current stage number (1-based)
- `floors_completed_in_current_stage: int` - Floors completed in current stage (0-based)
- `floors_per_stage: int` - Number of floors per stage (configurable, default: 10)

### Signals
- `stage_changed(new_stage: int)` - Emitted when advancing to a new stage
- `boss_floor_reached(stage: int)` - Emitted when reaching a boss floor
- `stage_completed(stage: int)` - Emitted when completing a stage

### Core Methods

#### Stage Information
- `get_current_stage() -> int` - Returns current stage number
- `get_floors_completed_in_current_stage() -> int` - Returns floors completed in current stage
- `get_floors_remaining_in_stage() -> int` - Returns floors remaining before boss
- `get_stage_progress() -> float` - Returns stage progress as 0.0-1.0

#### Stage Classification
- `is_boss_floor() -> bool` - True if current floor is a boss floor
- `is_early_stage() -> bool` - True if in first 30% of stage
- `is_mid_stage() -> bool` - True if in 30%-70% of stage  
- `is_late_stage() -> bool` - True if in 70%+ of stage (excluding boss)

#### Progression
- `advance_floor() -> void` - Advance to next floor in stage
- `complete_stage() -> void` - Complete current stage and advance to next
- `reset() -> void` - Reset to Stage 1, Floor 1 (for new runs)

#### Configuration
- `set_floors_per_stage(floors: int) -> void` - Configure floors per stage

#### Save/Load
- `get_save_data() -> Dictionary` - Get save data for persistence
- `load_save_data(data: Dictionary) -> void` - Load save data

#### Debug
- `get_debug_info() -> String` - Get formatted debug information

## Integration Points

### GameState Integration
The StageManager integrates with GameState in the following ways:
- `GameState.reset_run()` calls `StageManager.reset()`
- `GameState.next_floor()` calls `StageManager.advance_floor()`
- `GameState.get_save_data()` includes `StageManager.get_save_data()`
- `GameState.load_save_data()` calls `StageManager.load_save_data()`

### UI Integration
- Floor label shows stage information via `StageManager.get_debug_info()`
- Boss floors are visually indicated in the UI
- Stage progress can be displayed to show player advancement

### Future Integration Points
- **RoomManager**: Will use stage classification for room selection
- **QuestManager**: Will track quest progress per stage
- **Difficulty System**: Will scale based on stage number
- **Boss System**: Will select appropriate bosses based on stage

## Usage Examples

### Basic Usage
```gdscript
# Check if current floor is a boss floor
if StageManager.is_boss_floor():
    create_boss_room()
else:
    create_normal_room()

# Get stage information for UI
var info = StageManager.get_debug_info()
floor_label.text = info  # "Stage 2: Floor 3/10 [Mid] (30.0% progress)"
```

### Stage-based Room Selection
```gdscript
# Select room type based on stage progress
var room_type: String
if StageManager.is_early_stage():
    room_type = "easy_rooms"
elif StageManager.is_mid_stage():
    room_type = "medium_rooms"
elif StageManager.is_late_stage():
    room_type = "hard_rooms"
else:  # Boss floor
    room_type = "boss_rooms"
```

### Quest System Integration
```gdscript
# Example: Quest must complete before stage ends
func validate_quest_timing(quest_id: String) -> bool:
    var remaining_floors = StageManager.get_floors_remaining_in_stage()
    var quest_rooms_needed = get_quest_room_count(quest_id)
    return remaining_floors >= quest_rooms_needed
```

## Testing
The StageManager includes comprehensive unit tests in `test/StageManagerTest.gd`:
- Initial state validation
- Stage progression mechanics
- Progress calculation accuracy
- Boss floor detection
- Save/load functionality
- Reset functionality

Run tests with: `./run-tests.sh` or via Godot's test runner.

## Configuration
Currently hardcoded values that may become configurable:
- `DEFAULT_FLOORS_PER_STAGE = 10`
- Stage progress thresholds (30%, 70% for early/mid/late)

## Future Enhancements
1. **Stage Templates**: JSON configuration for stage-specific settings
2. **Variable Stage Length**: Different stages could have different lengths
3. **Stage Themes**: Visual/audio themes that change per stage
4. **Stage Modifiers**: Special rules or effects per stage
5. **Stage Completion Rewards**: Rewards for completing stages
6. **Stage Skip**: Ability to skip stages (for testing/accessibility)

## Dependencies
- **Required**: None (standalone singleton)
- **Integrates with**: GameState, RoomScreen UI
- **Future dependencies**: RoomManager, QuestManager, Difficulty System