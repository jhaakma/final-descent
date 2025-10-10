# Status Effect System Documentation

## Overview

The status effect system has been refactored to use a generic, component-based approach that follows the single responsibility principle. This makes it easy to add new status effects and manage them consistently across all entities.

## Architecture

### Core Components

1. **StatusEffect** (base class) - Defines the interface for all status effects
2. **StatusEffectComponent** (component) - Handles applying, tracking, and processing status effects
3. **StatusEffectResult** (data class) - Typed result from status effect application

### Key Classes

#### StatusEffect
- Base class for all status effects
- Handles common functionality like duration, stacking, and expiration
- Override `apply_effect()` to implement specific behavior

#### StatusEffectComponent
- Component attached to Player and Enemy classes
- Manages a collection of active status effects
- Processes all effects each turn and handles cleanup

#### StatusEffectResult
- Simplified data class for status effect results
- Contains effect name and optional message
- Used for communication between effects and calling code

## Usage Examples

### Creating a New Status Effect

```gdscript
class_name BurnEffect extends TimedEffect

@export var damage_per_turn: int = 3

func _init(dmg: int = 3, turns: int = 2):
    super._init("Burn", turns)
    damage_per_turn = dmg
    max_stacks = 2

func apply_effect(target) -> StatusEffectResult:
    var total_damage = int(damage_per_turn * get_stack_multiplier())
    target.take_damage(total_damage)

    # Log the damage with appropriate color
    LogManager.log_combat("Burns for %d damage!" % total_damage)

    return StatusEffectResult.new(
        effect_name,
        ""  # Empty message since we logged with proper color
    )
```

### Applying Status Effects

```gdscript
# In weapon or attack code
func apply_burn_to_target(target, damage: int, duration: int):
    var burn_effect = BurnEffect.new(damage, duration)
    target.status_effect_component.apply_effect(burn_effect)
```

### Processing Status Effects (Turn-Based)

```gdscript
# Status effects are processed in both Player.process_status_effects() and Enemy.process_status_effects()
# You can access all effects like this:
func process_all_status_effects():
    var results = status_effect_component.process_turn(self)
    for result in results:
        if result.message != "":
            print("Effect applied: %s - %s" % [result.effect_name, result.message])
```

## Benefits of the New System

1. **Single Responsibility**: Each class has one clear purpose
2. **Type Safety**: Uses typed data classes instead of dictionaries
3. **Extensibility**: Easy to add new status effects
4. **Code Reuse**: No duplication between Player and Enemy
5. **Consistency**: All status effects work the same way
6. **Stacking Support**: Built-in support for effect stacking
7. **Component-Based**: Uses composition over inheritance where appropriate

## Migration from Old System

The old poison-specific methods have been replaced with generic status effect methods:

**Old poison-specific methods (removed):**
- `apply_poison()` → `apply_status_effect(poison_effect)`
- `has_poison()` → `has_status_effect("Poison")`
- `process_poison()` → `process_status_effects()`
- `get_poison_description()` → `get_status_effect_description("Poison")`

**New generic status effect methods:**
- `apply_status_effect(effect: StatusEffect)` - Apply any status effect
- `has_status_effect(effect_name: String)` - Check for specific effect
- `process_status_effects()` - Process all effects and return results
- `get_status_effect_description(effect_name: String)` - Get specific effect description
- `remove_status_effect(effect_name: String)` - Remove specific effect
- `clear_all_status_effects()` - Remove all effects
- `get_status_effects_description()` - get all effect descriptions
- `get_all_status_effects()` - get array of all active effects

## Future Enhancements

This system is designed to be extended for:
- Stat modifier effects (buffs/debuffs)
- Conditional effects (triggers on certain actions)
- Permanent effects (until dispelled)
- Area effects (affecting multiple targets)
- Effect immunity and resistance