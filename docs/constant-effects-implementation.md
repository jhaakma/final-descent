# Constant Status Effects Implementation

## Overview

I've implemented a new `ConstantEffect` system that extends the existing status effect framework to support permanent or equipment-based status effects that don't expire naturally.

## Implementation Details

### 1. ConstantEffect Class (`src/effects/constant_effect.gd`)

- Extends `StatusEffect` (like `InstantEffect`)
- Provides permanent status effects that don't tick down or expire
- Has `is_removable` flag to distinguish between permanent and removable constant effects
- Includes `on_applied()` and `on_removed()` lifecycle methods
- Override `apply_effect()` for passive effects (most constant effects don't need active behavior)

### 2. StatusEffectComponent Updates

Updated `src/effects/status_effect_component.gd` to handle three types of effects:

1. **Instant Effects**: Applied immediately, not stored (existing behavior)
2. **Timed Effects**: Applied and stored, tick down each turn, expire (existing behavior)
3. **Constant Effects**: Applied and stored, never tick down or expire (new)

Key changes:
- Modified `apply_status_condition()` to detect and handle constant effects
- Updated `process_turn()` to skip ticking for constant effects
- Enhanced `remove_effect()`, `remove_condition()`, and `clear_all_effects()` to call lifecycle methods for constant effects

### 3. Example Constant Effects

Created two example constant effects in `src/effects/constant/`:

1. **StrengthBoostEffect**: Permanently increases strength stat
2. **FireResistanceEffect**: Provides constant fire damage resistance

### 4. Constant Effect Enchantment

Created `ConstantEffectEnchantment` (`src/enchantments/constant_effect_enchantment.gd`):
- Applies a constant effect when an item is equipped
- Automatically removes the effect when the item is unequipped
- Supports any type of constant effect
- Integrates with the Player's equipment system via direct method calls

### 5. Player Class Integration

Updated `src/core/Player.gd` to support constant effect enchantments:
- `equip_weapon()` now calls enchantment's `_on_weapon_equipped()` method
- `unequip_weapon()` now calls enchantment's `_on_weapon_unequipped()` method
- This ensures constant effects are properly applied/removed when equipment changes

### 6. Resource Files

Created data files for testing:
- `data/effects/constant/PermanentStrengthBoost.tres` (permanent +5 strength)
- `data/effects/constant/FireResistance.tres` (removable 50% fire resistance)
- `data/enchantments/FireResistanceEnchantment.tres` (equipment-based fire resistance)

## Use Cases

### Permanent Player Upgrades
```gdscript
# Apply a permanent strength boost (cannot be removed)
var permanent_boost = StrengthBoostEffect.new()
permanent_boost.strength_bonus = 5
permanent_boost.is_removable = false
player.apply_status_effect(permanent_boost)
```

### Equipment-Based Effects
```gdscript
# Create an enchanted weapon that provides fire resistance while equipped
var fire_sword = Weapon.new()
var resistance_enchantment = ConstantEffectEnchantment.new()
resistance_enchantment.constant_effect = FireResistanceEffect.new()
fire_sword.enchantment = resistance_enchantment
```

### Temporary Constant Effects
```gdscript
# Apply a removable constant effect (e.g., from a shrine blessing)
var blessing = StrengthBoostEffect.new()
blessing.strength_bonus = 2
blessing.is_removable = true
player.apply_status_effect(blessing)

# Later remove it
player.remove_status_effect(blessing)
```

## Integration with Existing Systems

- **Combat**: Constant effects persist through all combat turns without expiring
- **Equipment**: Use `ConstantEffectEnchantment` for equipment-based constant effects
- **Player Progression**: Use permanent constant effects for unlockable upgrades
- **Status Effect UI**: Constant effects show in status lists without turn counters
- **Save/Load**: Constant effects are stored with active conditions and persist

## Design Decisions

1. **Inheritance**: Extended `StatusEffect` directly (not `TimedEffect`) to avoid unnecessary duration logic
2. **Storage**: Constant effects are stored in `active_conditions` like timed effects but never expire
3. **Lifecycle**: Provided `on_applied()` and `on_removed()` for setup/cleanup logic
4. **Flexibility**: `is_removable` flag allows both permanent and removable constant effects
5. **Equipment Integration**: `ConstantEffectEnchantment` handles automatic application/removal

## Future Enhancements

- **Stacking**: Support for multiple instances of the same constant effect
- **Conditional Effects**: Constant effects that activate only under certain conditions
- **Effect Modifiers**: Constant effects that modify other effects rather than direct stats
- **Aura Effects**: Constant effects that affect nearby entities rather than just the bearer

## Notes

- The system maintains backward compatibility with existing instant and timed effects
- Lint errors in development are expected until Godot processes the new class files
- Constant effects are ideal for stat modifications, resistances, and passive abilities
- Use sparingly for active effects that trigger each turn (prefer timed effects for those)