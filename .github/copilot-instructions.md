# Copilot Instructions for Final Descent

Godot 4 roguelike dungeon crawler game guidelines.

## Core Principles

- **Architecture**: Single responsibility, component-based design, strict typing (`var health: int`)
- **Logic**: Use enums/constants/dictionaries, avoid string matching
- **Godot**: Use 4.4 APIs, add methods only when needed
- **Style**: Spaces not tabs, UI in `.tscn` files, dictionaries over match statements
- **Enums**: Use enums for fixed sets of values, never use int as types when referencing enums

## Project Structure

- `data/`: Game resources (`.tres` files for items/spells/enemies)
- `src/`: Scripts organized by feature
- `test/`: Automated tests
- `docs/`: Technical documentation

## Development

- **Godot Path**: `"C:\Development\Godot 4\Godot_v4.4.1-stable_win64_console.exe"`
- **Resources**: Don't create programmatically, match existing UIDs or let user create first
- **Error Handling**: `push_error()` for dev errors, user feedback for gameplay

## Testing

- **Run**: `make test` or `make test filter=TestName` (filter only works on one class or method name)
- **Files**: Extend `BaseTest`, methods start with `test_`, return `bool`
- **Structure**: Separate files per feature (`ScrollTest.gd`, `PotionTest.gd`)

## Game Patterns

- Items extend `Item` base class
- Use status effect system for temporary modifications
- Load data from `.tres` files over hardcoded values
- Use `GameState`, avoid singletons when possible

## Quality

- Write tests before implementation when possible
- Follow existing codebase patterns
- Use object pooling and `queue_free()` properly
- Provide git commit messages in code blocks for completed tasks