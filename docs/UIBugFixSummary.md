# UI Sync Bug Fix and Refactoring Summary

## Bug Fixed
**Issue**: Poison duration didn't update in UI when killing an enemy, but damage was applied. Duration appeared to decrease by 2 turns when entering next room.

**Root Cause**:
- `CombatManager.end_combat()` processes final ROUND_END effects (poison damage + duration decrement)
- `InlineCombat._on_combat_ended()` didn't call `combat_ui.update_display()` to show updated status effects
- `_on_round_ended()` did call it, causing inconsistency
- Next room's `process_all_timed_effects()` decremented again, appearing like 2 turns passed

**Fix**: Added `combat_ui.update_display()` in `_on_combat_ended()` handler

## Refactoring - Reactive UI Updates

### Problem
Manual `update_display()` calls scattered throughout combat code made it easy to miss UI updates (like the bug above).

### Solution: Signal-Based Reactive Pattern

#### Changes Made:
1. **CombatUI now listens to Player.stats_changed signal** (reactive)
   - Connected in `initialize_combat_display()`
   - Created `_on_player_stats_changed()` callback
   - Removed manual `stats_changed.emit()` from `_refresh_bars()`

2. **Player now emits stats_changed on all stat changes**
   - Added emit in `_on_health_changed()` for HP updates
   - Already had emits for status effect changes

3. **Manual updates kept where appropriate**
   - Enemy stats updates (enemy doesn't have signal system)
   - Button state updates (based on turn state, not data changes)

### Benefits
- **Impossible to forget player stat UI updates** - happens automatically when Player data changes
- **Single source of truth** - Player emits stats_changed, UIs react
- **Easier to maintain** - no need to remember where to call updates for player stats
- **Decoupled** - Player doesn't know about UI, UI listens to Player
- **Consistent** - All player stat changes (HP, status effects, bonuses) trigger UI updates

### Files Modified
- `src/ui/components/inline_combat.gd` - Added update in `_on_combat_ended()`
- `src/combat/ui/CombatUI.gd` - Added signal connection, made `_refresh_bars()` reactive
- `src/core/Player.gd` - Emit `stats_changed` when health changes
- `docs/UIRefactoringPlan.md` - Full refactoring plan documentation

## Testing Needed
1. Kill enemy while poisoned - verify poison duration decrements by 1 turn in UI
2. Move to next room - verify poison decrements by 1 turn (not 2)
3. Take damage in combat - verify HP bar updates
4. Apply/remove status effects - verify they update in UI immediately
5. Test all combat flows (player first, enemy first, fleeing, victory, defeat)
