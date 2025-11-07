# Ability Template System

## Overview
The ability template system allows dynamic generation of abilities based on templates. Templates generate instances of AbilityResource subclasses (AttackAbility, DefendAbility, etc.) with properties determined by the user's stats and configuration at generation time.

## Architecture

### Base Class: AbilityTemplate
Located in `src/abilities/templates/AbilityTemplate.gd`

Simple interface with one method:
```gdscript
func generate_ability(_user = null) -> AbilityResource
```

The `user` parameter can be any object that implements relevant methods like `get_level()` and `get_element_affinity()`. Templates use duck typing to extract properties from the user.

### Concrete Implementations

#### BasicAttackTemplate
- Generates standard attack abilities
- No user properties needed
- Priority: 10, no base damage (uses user's attack stat)

#### BasicStrikeTemplate
- Generates strike abilities with bonus damage
- Uses `user.get_level()` if available
- Priority: 8, base damage: 2 + level

#### ElementalStrikeTemplate
- Generates elemental-infused strike abilities
- Uses `user.get_level()` and `user.get_element_affinity()` if available
- Name generated based on element (e.g., "Fire Strike")
- Priority: 7, base damage: 3 + level

#### BreathAttackTemplate
- Generates breath weapon abilities
- Uses `user.get_level()` and `user.get_element_affinity()` if available
- Name generated based on element (e.g., "Fire Breath")
- Priority: 6, base damage: 5 + (level * 2), cooldown: 3 turns

#### PoisonAttackTemplate
- Generates poison-based attacks
- Uses `user.get_level()` if available
- Applies poison status effect (ElementalTimedEffect)
- Priority: 7, base damage: 2 + level

#### DefendTemplate
- Generates defensive stance abilities
- No user properties needed
- Priority: 5

## Usage

### In Code (EnemyTemplate)
Use the helper methods for easy configuration:

```gdscript
var template := EnemyTemplate.new()
template.base_name = "Fire Dragon"
template.base_level = 5
template.element_affinity = EnemyTemplate.ElementAffinity.FIRE

# Add abilities using chainable helper methods
template.add_basic_attack()
    .add_elemental_strike()
    .add_breath_attack()
    .add_defend()
```

### In Resources (.tres files)
Create ability template resources and add them to the `ability_templates` array in EnemyTemplate resources. When enemies are generated, the templates will extract properties from the EnemyResource (level, element_affinity) to generate appropriate abilities.

## How It Works

1. **EnemyTemplate Configuration**: Set up the enemy template with base properties (level, element affinity, etc.)
2. **Enemy Generation**: `EnemyGenerator` creates an `EnemyResource` and populates it with the template's properties
3. **Ability Generation**: Templates are passed the `EnemyResource` and dynamically generate abilities by extracting properties via duck-typed method calls
4. **Runtime Execution**: The generated `AbilityResource` instances are stored in the `EnemyResource` and later used by the `Enemy` combat entity

### Data Flow
```
EnemyTemplate (base_level, element_affinity)
    ↓
EnemyGenerator.generate_enemy_from_template()
    ↓
EnemyResource (level, element_affinity) created
    ↓
ability_template.generate_ability(enemy_resource)
    ↓ (extracts level and element_affinity)
AbilityResource created with dynamic properties
```

## Key Benefits

1. **Dynamic Generation**: Abilities adapt to entity properties at generation time
2. **Flexibility**: Duck typing allows templates to work with any object that has the needed methods
3. **No Pre-configuration**: Templates don't need to be configured beforehand - they extract what they need
4. **Type Safety**: Templates return properly configured AbilityResource instances
5. **Extensibility**: Easy to add new template types without modifying existing code
6. **Reusability**: Templates can be saved as resources and reused across enemies

## Deprecated Code
- `AbilityResolver` class is deprecated and should not be used
- `EnemyTemplate.AbilityTemplate` enum has been removed
- Use the new template system instead

## Future Enhancements
- Player ability templates
- Buff/heal ability templates (currently stubbed)
- More complex conditional generation based on user stats
- Template inheritance/composition
