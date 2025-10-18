# Copilot Instructions for Final Descent

This is a Godot 4 roguelike dungeon crawler game. Follow these guidelines when working on the project.

## Architecture & Design Principles

- **Single Responsibility Principle**: Each mechanic should be implemented in its own class or function
- **Component-based Design**: Use components to encapsulate related functionality
- **Strict Typing**: Always use explicit type annotations (`var health: int`, `func get_name() -> String`)
- **Avoid String-based Logic**: Don't rely on string matching for game logic - use enums, constants, or dictionaries
- **Modern Godot Practices**: Use current Godot 4.4 APIs and patterns, avoid deprecated methods
- **Method Philosophy**: Add methods only when needed, not "just in case"

## Code Style & Standards

- **Indentation**: Use spaces, not tabs
- **UI Separation**: Put UI formatting and styling in scene files (`.tscn`), not code
- **Dictionary over Match**: Prefer dictionaries for mapping/lookup operations instead of match statements
- **No Redundant Documentation**: Don't create README files for every small change

## Project Structure

- **Data Resources**: Game data (items, spells, enemies) stored in `.tres` files under `data/`
- **Source Code**: All scripts in `src/` directory, organized by feature
- **Scenes**: UI and game scenes in appropriate subdirectories
- **Documentation**: Technical docs in `docs/` directory
- **Tests**: Automated tests in `test/` directory

## Development Environment

- **Godot Executable**: Located at `"C:\Development\Godot 4\Godot_v4.4.1-stable_win64_console.exe"`
- **Command Line**: Godot can be run via command line for testing and automation
- **Resource Creation**: Don't create example resources programmatically - they won't work properly

## Testing Guidelines

- **Test Framework**: Write tests for new features and bug fixes using the automated test system
- **Run Tests**: Use convenient scripts: `./run-tests.sh`, `run-tests.bat`, `.\run-tests.ps1`, or `make test`
- **Manual Run**: Execute `godot --headless res://test/test_runner.tscn` to run all tests
- **Test File Creation**: Add new test files ending in `Test.gd` in `test/` directory
- **Test Base Class**: All test classes should extend `BaseTest` for assertion helpers
- **Test Method Naming**: Test methods must start with `test_` and return `bool`
- **Assertion Methods**: Use `BaseTest` helpers like `assert_true()`, `assert_equals()`, `assert_resource_loads()`
- **Auto-Discovery**: Tests are automatically discovered - no manual registration needed
- **Organization**: Create separate test files for different features (e.g., `ScrollTest.gd`, `PotionTest.gd`)
- **Documentation**: Comprehensive testing guide available at `docs/testing-guide.md`

## Game-Specific Patterns

- **Items**: All items extend `Item` base class with proper categories and behavior
- **Status Effects**: Use the status effect system for temporary modifications
- **Combat**: Combat entities handle health, abilities, and status conditions
- **Resource Loading**: Prefer loading game data from `.tres` files over hardcoded values
- **State Management**: Use `GameState` for global game state, avoid singletons when possible

## Implementation Guidelines

- **Return Values**: Methods that can fail should return boolean or appropriate error types
- **Error Handling**: Use `push_error()` for development errors, proper user feedback for gameplay failures
- **Performance**: Prefer object pooling for frequently created/destroyed objects
- **Memory**: Call `queue_free()` on nodes when done, avoid memory leaks

## Quality Assurance

- **Test Coverage**: Write tests for new features before implementation when possible
- **Regression Testing**: Run full test suite before committing changes
- **Code Review**: Follow established patterns in existing codebase
- **Documentation**: Update relevant docs when adding significant features

## Git Guidelines
- **Commit Messages**: When completing a task, give a summary in the form of a git commit message, inside a code block
- **Be concise**: Commit messages should omit small details, and combine related bullet points