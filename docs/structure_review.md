# Project Structure Review

## Updated Layout (Post-Migration)
- Executable code now lives under a consolidated `src/` tree with feature-focused modules such as `src/abilities/`, `src/components/`, `src/rooms/`, `src/ui/`, and `src/core/` for global singletons.
- Data assets (scenes, resources, balance tables, styles) have been moved into a parallel `data/` tree (`data/rooms/`, `data/items/`, `data/ui/`, etc.) to keep tweakable content separate from logic.
- UI scripts reside in `src/ui/` while their scenes and themes are stored in `data/ui/`, ensuring reusable widgets and popups stay discoverable alongside their resources.
- Shared utilities like logging and helper functions are grouped in `src/shared/`, and tooling scripts sit under `src/tools/` to highlight their reuse potential.

## Previous Layout Overview
- Core gameplay scripts for abilities, enemies, items, components, and effects sit directly under top-level folders (for example, `abilities/Ability.gd` and `enemies/enemy.gd`).
- Resource data such as rooms, item picks, and enemy definitions reside in the `resources/` hierarchy (for example, `resources/rooms/CombatRoomEasy.tres`).
- Scene files are split across `scenes/`, `screens/`, and `uielements/`, while UI styles are placed under `Styles/`.
- Global singleton scripts like `Player.gd`, `GameStats.gd`, and `game_state.gd` remain at the repository root alongside utility scripts.

## Legacy Observations
The following notes describe the pain points that motivated the migration and are retained for historical context.
1. **Code and Data Co-located**  
   Many gameplay scripts live side-by-side with their resource data (e.g., enemy scripts in `enemies/` referenced by `resources/enemies/`). This makes it harder to isolate logic from tunable content and complicates exporting balance tables.
2. **Mixed Granularity in Folder Hierarchy**  
   Some folders group by domain (`abilities/`, `effects/`), while others group by presentation (`screens/`, `uielements/`). Root-level singleton scripts bypass both conventions, reducing discoverability.
3. **Limited Reusability Cues**  
   Shared systems such as inventory, combat components, and utilities are spread between `components/`, the root directory, and UI-specific folders, making it difficult to identify reusable modules.
4. **Inconsistent Resource Grouping**  
   Data resources for encounters, items, and abilities live under `resources/`, but supporting assets (e.g., loot tables, achievements) are located elsewhere or mixed with logic, reducing the effectiveness of tools like the Resources as Tables plugin.

## Recommendations
1. **Introduce `/src` and `/data` Roots**  
   - Move all executable GDScript files into a `src/` hierarchy organized by feature (e.g., `src/combat/`, `src/items/`, `src/ui/`).  
   - Place `.tres` and other data assets into a dedicated `data/` tree that mirrors the feature structure (`data/enemies/`, `data/rooms/`). This keeps code and tweakable data clearly separated for both developers and designers.
2. **Normalize Feature Modules**  
   - Within `src/`, create feature modules (combat, progression, ui, meta) each with subfolders for components, services, and state objects.  
   - Migrate root singletons (`GameStats.gd`, `game_state.gd`, `Player.gd`) into a `src/singletons/` or `src/core/` module to centralize global logic.  
   - Co-locate feature-specific resources under matching data folders to aid discoverability.
3. **Group UI Scenes and Themes**  
   - Combine `screens/`, `uielements/`, and `Styles/` into `src/ui/` (code) and `data/ui/` (themes, style resources).  
   - Adopt subdirectories such as `src/ui/screens/`, `src/ui/widgets/`, and `data/ui/themes/` so reusable UI widgets are easy to reuse across screens.
4. **Create Shared Systems Library**  
   - Gather reusable gameplay infrastructure (inventory components, status effects, logging, utilities) into `src/shared/` with clear namespaces (`src/shared/inventory/`, `src/shared/effects/`).  
   - Expose these modules via autoloads or dependency injection to prevent unrelated features from depending on folder location.
5. **Standardize Resource Tables**  
   - Mirror the code module structure under `data/` to leverage the Resources as Tables plugin (e.g., `data/combat/rooms/CombatRoomEasy.tres`).  
   - Add README files in each data subfolder to document schema expectations, enabling designers to edit tables without diving into scripts.
6. **Document Ownership Boundaries**  
   - Provide a `docs/ARCHITECTURE.md` (or expand this review) describing module responsibilities and how code/data travel between them.  
   - Include guidance on where new features should live to maintain the separation and reusability goals.

## Suggested Next Steps
1. Open the project in Godot to validate that import metadata and UUID references remain intact after the filesystem moves.
2. Expand the documentation (e.g., `docs/ARCHITECTURE.md`) to codify module ownership and provide onboarding guidance for adding new features under `src/` and `data/`.
3. Introduce tooling or CI checks that prevent regressions (such as scripts that ensure scripts land in `src/` and resources in `data/`).
4. Update contributor guidelines to highlight the new layout and expectations for separating code from tunable content.
