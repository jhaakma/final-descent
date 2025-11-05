# UI Event Bus Architecture

## Problem
Complex signal chains made UI updates fragile and hard to maintain. The poison duration bug occurred because UI update calls were scattered throughout the codebase and easy to miss.

## Solution: Centralized UI Event Bus

### Architecture
**UIEvents** - Global autoload singleton that acts as a centralized event bus for all UI updates.

### Benefits
1. **Decoupling** - Game logic doesn't need to know about UI components
2. **Simplicity** - Single source of truth for UI update events
3. **Maintainability** - UI components listen to one place, not multiple signal chains
4. **Reliability** - Hard to forget UI updates when they're centralized

### How It Works

#### Event Emitters (Game Logic)
```gdscript
# Player emits to UIEvents when stats/effects change
func _on_health_changed():
    UIEvents.player_stats_changed.emit()

func _on_effect_changed():
    UIEvents.player_status_effects_changed.emit()

# CombatManager emits after processing combat effects
func end_combat():
    context.player.process_status_effects()  # Process effects
    UIEvents.player_stats_changed.emit()     # Notify UI
```

#### Event Listeners (UI Components)
```gdscript
# RoomScreen listens to UIEvents
func _ready():
    UIEvents.player_stats_changed.connect(_on_stats_changed)
    UIEvents.player_status_effects_changed.connect(_on_status_effects_changed)

func _on_stats_changed():
    _refresh_stats()

func _on_status_effects_changed():
    _refresh_buffs()
```

### Signal Types

**player_stats_changed** - HP, attack, defense changes
**player_inventory_changed** - Items added/removed/equipped
**player_status_effects_changed** - Status effects applied/processed/removed
**ui_refresh_requested** - Request full UI refresh

### Migration Path

1. **Phase 1** ✅ - Create UIEvents autoload
2. **Phase 2** ✅ - Emit UIEvents from Player and CombatManager
3. **Phase 3** ✅ - Connect UI components to UIEvents
4. **Phase 4** (Future) - Remove legacy GameState signals once all components migrated

### Files Modified
- `src/globals/UIEvents.gd` (new) - Event bus singleton
- `project.godot` - Register UIEvents autoload
- `src/core/Player.gd` - Emit UIEvents on status effect changes
- `src/combat/CombatManager.gd` - Emit UIEvents after combat end
- `src/ui/screens/room_screen.gd` - Listen to UIEvents
- `src/ui/components/inline_combat.gd` - Simplified combat end handling

### Result
UI updates are now reliable and centralized. The poison duration bug is fixed because:
1. CombatManager processes ROUND_END effects
2. CombatManager emits UIEvents.player_stats_changed
3. RoomScreen receives signal and refreshes buffs
4. Poison duration displays correctly

No more scattered `update()` calls or complex signal chains!
