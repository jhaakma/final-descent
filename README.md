# Final Descent

A roguelike dungeon crawler built with Godot 4, featuring turn-based combat, magic spells, consumable items, and procedurally generated encounters.

## Summary

Final Descent is a classic dungeon crawler that combines strategic turn-based combat with roguelike elements. Players descend through increasingly dangerous floors, battling enemies, collecting loot, and managing resources. The game features a comprehensive magic system with spells and scrolls, various consumable items like potions and elixirs, weapon degradation mechanics, and status effects that add tactical depth to combat encounters.

## Features

### Core Gameplay
- **Turn-based Combat**: Strategic combat system with abilities, spells, and status effects
- **Procedural Rooms**: Randomly generated encounters including combat, treasure chests, shops, shrines, and rest areas
- **Character Progression**: Equipment upgrades and resource management as you descend deeper
- **Roguelike Elements**: Permadeath with high score tracking and procedural content

### Combat System
- **Abilities**: Attack, defend, flee, and special combat abilities like Battle Rage and Power Strike
- **Status Effects**: Poison, burn, frostbite, and other tactical conditions that persist across turns
- **Weapon Degradation**: Equipment wears down over time, requiring repair or replacement
- **Enchantments**: Magical weapon enhancements adding fire, ice, or shock damage

### Magic & Items
- **Spell System**: Castable spells with mana costs including Firebolt, Frostbolt, and Poisonbolt
- **Scrolls**: Single-use spell items for strategic resource management
- **Potions**: Health restoration, antidotes, and regeneration effects
- **Elixirs**: Powerful consumables with lasting effects
- **Repair Tools**: Maintain weapon condition during your descent

### Room Types
- **Combat Encounters**: Face various enemies from rats and goblins to dragons and spectres
- **Treasure Rooms**: Discover chests with valuable loot
- **Shopkeeper Rooms**: Trade with merchants for gear and supplies
- **Shrine Rooms**: Ancient and evil shrines offering mysterious benefits
- **Rest Areas**: Safe spaces to recover health and prepare for challenges
- **Mimic Encounters**: Dangerous treasure mimics that fight back

### Technical Features
- **Component-Based Architecture**: Modular design with single responsibility principle
- **Resource-Driven Content**: Game data stored in `.tres` files for easy modification
- **Automated Testing**: Comprehensive test suite with automatic test discovery
- **Strict Typing**: Full type annotations for code reliability
- **Modern Godot 4 Practices**: Uses current APIs and best practices

## Testing

Final Descent includes a robust automated testing framework to ensure code quality and catch regressions.

### Running Tests

**Via Makefile:**

```bash
make test              # Any platform with Make
```

**Manual Execution:**
```bash
godot --headless res://test/test_runner.tscn
```

### Writing New Tests

Create test files in the `test/` directory:

```gdscript
class_name YourFeatureTest extends BaseTest

func test_your_feature_works() -> bool:
    var result = your_feature_function()
    return assert_true(result)

func test_resource_loads() -> bool:
    return assert_resource_loads("res://data/your_resource.tres")
```

### Available Assertions

- `assert_true(condition)` / `assert_false(condition)`
- `assert_equals(actual, expected)`
- `assert_not_null(value)` / `assert_null(value)`
- `assert_resource_loads(path)` - Validates resource file loading
- `assert_has_method(object, method_name)` - Checks method existence
- `assert_string_contains(text, substring)` - String content validation

For detailed testing information, see the [Testing Guide](docs/testing-guide.md).

## Development

### Requirements
- Godot 4.4.1 or later
- Windows, macOS, or Linux development environment

### Project Structure
```
data/           # Game content resources (.tres files)
src/            # Source code organized by feature
test/           # Automated test suite
docs/           # Technical documentation
```
