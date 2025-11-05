# UI Sync Refactoring Plan

## Problem
Manual `update_display()` calls scattered throughout combat code, making it easy to miss UI updates (like the poison duration bug when combat ends).

## Root Cause
- UI updates are imperative rather than reactive
- CombatUI manually emits player.stats_changed instead of listening to it
- StatusEffectComponent emits signals but nothing listens to them

## Solution: Signal-Based Reactive UI

### Phase 1: Connect StatusEffectComponent signals to Player (COMPLETED)
Player already overrides status effect methods to emit stats_changed when:
- `apply_status_effect()` succeeds
- `apply_status_condition()` succeeds
- `remove_status_effect()` called
- `remove_status_condition()` succeeds
- `clear_all_negative_status_effects()` called

This is already working correctly!

### Phase 2: Make CombatUI reactive (TO DO)
Currently:
```gdscript
# CombatUI._refresh_bars() manually emits the signal (BAD)
context.player.stats_changed.emit()
```

Should be:
```gdscript
# CombatUI should LISTEN to the signal and auto-update (GOOD)
# In setup:
context.player.stats_changed.connect(_on_player_stats_changed)

# Then just update when signaled:
func _on_player_stats_changed() -> void:
    _refresh_bars()
```

### Phase 3: Remove manual update_display() calls
Once CombatUI is reactive:
- Remove `combat_ui.update_display()` from inline_combat.gd signal handlers
- The UI will update automatically when stats change
- Only keep manual updates for initial display setup

### Benefits
1. **Impossible to forget UI updates** - happens automatically when data changes
2. **Single source of truth** - Player emits stats_changed, UI reacts
3. **Easier to maintain** - no need to remember where to call updates
4. **Decoupled** - Combat logic doesn't know about UI updates
5. **Consistent** - All stat changes trigger UI updates the same way

### Implementation Steps ✅ COMPLETED
1. ✅ Add signal connections in CombatUI.initialize_combat_display()
2. ✅ Make _refresh_bars() reactive via _on_player_stats_changed() callback
3. ✅ Remove manual stats_changed.emit() from CombatUI._refresh_bars()
4. ✅ Add stats_changed emit in Player._on_health_changed() for HP updates
5. ✅ Keep update_display() calls for enemy stats and button states (non-reactive)

### Files Modified
- `src/combat/ui/CombatUI.gd` - Added signal connection, made _refresh_bars reactive
- `src/core/Player.gd` - Emit stats_changed when health changes
- `src/ui/components/inline_combat.gd` - Added update in _on_combat_ended for bug fix

### Result
- **Player stats**: Fully reactive - any HP or status effect change auto-updates UI
- **Enemy stats**: Manual updates at turn boundaries (enemy doesn't have signals)
- **Button states**: Manual updates at turn boundaries (based on game state)
- **Bug fixed**: Poison duration now updates correctly when enemy dies
