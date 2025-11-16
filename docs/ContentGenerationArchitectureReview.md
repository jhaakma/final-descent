# Content Generation Architecture Review

## Current Architecture Overview

The game uses a **Template → Generator → Resource → Instance** pattern for dynamic content generation:

```
Template (.tres config) → Generator (combines template + materials) → Resource (game data) → Instance (runtime entity)
```

### System Breakdown by Content Type

#### 1. **Enemies** (Most Mature)
```
EnemyTemplate → EnemyGenerator → EnemyResource → Enemy (CombatEntity)
```

**Strengths:**
- Clean separation: Template defines archetype/affinity, Generator applies level scaling
- `AbilityTemplate` system provides elegant level-based scaling for abilities
- Duck-typed `generate_ability(user)` allows templates to extract properties flexibly
- Caching prevents duplicate enemy generation
- Helper methods (`.add_basic_attack()`) make templates easy to configure in code
- Works seamlessly with `.tres` resources for designer-friendly configuration

**Pattern:**
- Templates are pure configuration (enums, base values, ability template references)
- Generator handles all math/scaling logic
- Resource is passive data container
- Instance is runtime combat entity

#### 2. **Weapons/Armor** (Simpler but Inconsistent)
```
WeaponTemplate + WeaponMaterial → WeaponGenerator → Weapon (Item)
ArmorTemplate + ArmorMaterial → ArmorGenerator → Armor (Item)
```

**Issues:**
- **Template/Material split seems unnecessary for current complexity**
  - Templates are just name + base stats (5 properties)
  - Materials are just name + 3 multipliers
  - Result: `"Iron Dagger"` = combine template + material
  - This is elegant for procedural generation but **never actually used**

- **Bypassed by hand-crafted items**
  - Most weapons are `.tres` files with hardcoded stats (`Staff.tres`, `Dagger.tres`)
  - Generators exist but aren't integrated into loot system
  - No level scaling - a Staff is always 5 damage regardless of floor

**Observations:**
- The template+material system anticipates procedural "Steel Longsword" generation
- But the game uses curated items instead
- This creates dead code and confusion about which approach to use

#### 3. **Rooms** (Lightweight Templates)
```
RoomTemplate → RoomResource → Room Screen (UI)
```

**Strengths:**
- Templates are very simple: just arrays of strings and stage scaling multipliers
- `IRoomTemplate.generate_room(stage)` applies scaling formulas
- Caching works well (by template + stage)
- NEW: `StatusConditionTemplate` for shrine blessings follows ability template pattern nicely

**Pattern:**
- Templates define variants and base costs
- Generation applies linear scaling by stage
- Resources are passive containers consumed by UI

#### 4. **Abilities** (Template-Only, No Generator)
```
AbilityTemplate → AbilityResource (no intermediate step)
```

**Strengths:**
- Simplest pattern: `template.generate_ability(user) → AbilityResource`
- No separate Generator class needed
- Works perfectly for enemies (scales by enemy level)
- NEW: Proved successful for shrine blessings (scales by player floor)

**Key Insight:**
- This is actually the cleanest pattern in the codebase
- No unnecessary Generator middleman
- Templates are self-contained and reusable

---

## Architecture Patterns Comparison

### Pattern A: Template + Generator + Resource
**Used by:** Enemies, Weapons, Armor

```gdscript
# Configuration
var template = EnemyTemplate.new()
template.base_level = 5

# Generation (with complex logic)
var generator = EnemyGenerator.new()
var resource = generator.generate_from_template(template)

# Runtime
var instance = Enemy.new(resource)
```

**When useful:**
- Need to combine multiple inputs (template + materials + modifiers)
- Complex generation logic (archetype stats, size multipliers, resistance calculation)
- Want to cache expensive generation
- Multiple templates share generation logic

### Pattern B: Template → Resource (Direct)
**Used by:** Abilities, StatusConditions, (New) Shrine Blessings

```gdscript
# Configuration
var template = StrengthBlessingTemplate.new()

# Generation (simple, self-contained)
var resource = template.generate_condition(user)

# Runtime
user.apply_status_condition(resource)
```

**When useful:**
- Simple generation (just apply formulas to user properties)
- No need to combine multiple inputs
- Template logic is specific to that type
- One template per generated type

### Pattern C: Direct Resource Creation
**Used by:** Handcrafted items (Staff.tres), Potions, some Enemies

```gdscript
# Configuration (in .tres file or code)
var weapon = Weapon.new()
weapon.damage = 5
weapon.name = "Staff"
```

**When useful:**
- Unique, curated content
- No procedural variation needed
- Designer wants exact control
- No scaling required

---

## Problems & Observations

### 1. **Over-Engineering for Current Needs**

**Item Generation:**
- WeaponGenerator/ArmorGenerator exist but aren't used
- All weapons/armor in loot are `.tres` files
- Template+Material system designed for procedural generation that never happens
- Result: Maintenance burden for unused code

**Evidence:**
```gdscript
// In loot tables and shops:
ExtResource("Staff.tres")  // Hardcoded weapon
ExtResource("HealthPotion.tres")  // Hardcoded potion

// Generators exist but never called:
WeaponGenerator.generate_item()  // Dead code
```

### 2. **No Item Scaling**

Items don't scale with floor/level:
- Staff is always 5 damage (floor 1 or floor 20)
- Potions always heal 10 HP
- Armor always gives +5 defense

This creates balance issues as enemies scale but items don't.

**Potential fix:**
- Add item level to resources
- Scale stats when generating loot based on current floor
- Use templates for this (like abilities do)

### 3. **Inconsistent Template Usage**

Three different approaches coexist:
1. Enemy: Template → Generator → Resource (full pipeline)
2. Ability: Template → Resource (lightweight)
3. Item: Direct Resource (no template)

This inconsistency makes it unclear when to use which approach.

### 4. **Generator Classes Add Indirection**

For simple cases, generators are just wrappers:

```gdscript
// WeaponGenerator essentially just does:
func generate_item() -> Item:
    var weapon = Weapon.new()
    weapon.damage = template.base_damage * material.damage_modifier
    return weapon
```

This could be on the template itself:
```gdscript
// Template could handle it:
func generate_weapon(material: WeaponMaterial) -> Weapon:
    var weapon = Weapon.new()
    weapon.damage = base_damage * material.damage_modifier
    return weapon
```

### 5. **Cache Management is Manual**

Each generator manages its own cache:
```gdscript
var cache: Dictionary = {}  // In EnemyGenerator
var cache: Dictionary = {}  // In WeaponGenerator
static var cache: Dictionary = {}  // In RoomGenerator
```

No unified caching strategy or cache invalidation.

---

## Recommendations

### Option 1: Embrace Direct Templates (Simplify)

**Remove generators entirely, use template pattern everywhere:**

```gdscript
// Weapons
var weapon_template = WeaponTemplate.new()
weapon_template.base_damage = 5
var weapon = weapon_template.generate(floor_level, material)

// Same pattern as abilities/blessings
```

**Pros:**
- Simplest architecture
- Follows successful ability template pattern
- Less code to maintain
- Clear what generates what

**Cons:**
- Loses separation of concerns
- Cache management on templates feels odd
- Less flexible for complex combinations

### Option 2: Standardize on Generator Pattern

**Keep generators but make them consistent:**

```gdscript
// All generators follow same interface
class_name ContentGenerator extends Resource
    func generate(context: GenerationContext) -> Resource
    func cache_key(template: Template) -> String
```

**Pros:**
- Unified pattern across all content
- Clear place for generation logic
- Easier to add cross-cutting concerns (caching, modifiers)

**Cons:**
- More boilerplate for simple cases
- Still have indirection

### Option 3: Hybrid Approach (Recommended)

**Use templates for simple cases, generators for complex:**

**Simple (Template only):**
- Abilities ✓ (already done)
- Status conditions ✓ (just added)
- Rooms (could be simplified)
- Potions/Scrolls

**Complex (Generator + Template):**
- Enemies (needs archetype calculation, modifiers)
- Procedural weapons (IF we add this feature)
- Procedural armor (IF we add this feature)

**Curated (Direct Resources):**
- Unique weapons/armor (keep as .tres)
- Special enemies (bosses)
- Unique items

**Changes needed:**
1. **Add item scaling** - Items need level context for generation
2. **Remove unused generators** - Delete WeaponGenerator/ArmorGenerator if not using procedural items
3. **Add ItemTemplate** - For scaling handcrafted items by floor
4. **Unified cache** - Create CacheManager for all generators/templates

---

## Specific Actionable Items

### High Priority

1. **Item Scaling System**
   ```gdscript
   class_name ItemTemplate extends Resource
       func apply_level_scaling(item: Item, level: int) -> void
   ```
   - Scale weapon damage, armor defense, potion healing by floor
   - Use when generating loot

2. **Simplify Room Templates**
   - Remove RoomGenerator helper class
   - Move caching into templates themselves
   - Rooms are simple enough to not need generators

3. **Document Pattern Usage**
   - Add architectural decision records (ADRs)
   - State when to use templates vs generators vs direct resources
   - Example: "Use templates for content that scales with level"

### Medium Priority

4. **Unified Caching**
   ```gdscript
   # Global cache service
   class_name ContentCache extends Node
       func get_or_create(key: String, generator: Callable) -> Resource
   ```

5. **Remove Dead Code**
   - If not doing procedural items, delete WeaponGenerator/ArmorGenerator
   - Or document why they exist (future feature)

6. **Template Helper Utilities**
   - Math helpers for scaling formulas
   - Naming utilities for procedural names
   - Material combination logic

### Low Priority

7. **Template Inheritance**
   - Share scaling logic between similar templates
   - Example: StrengthBlessingTemplate + DefenseBlessingTemplate could extend BaseStatBlessingTemplate

8. **Generation Context Object**
   - Pass context instead of individual params
   - `generate(context)` where context has floor, player_level, rarity, etc.

---

## Conclusion

**Current State:**
The architecture is **well-designed but over-engineered for current needs**. The template→generator→resource pattern makes sense for enemies (complex generation), but is overkill for items (which are handcrafted). The new ability template system is actually the cleanest part of the codebase.

**Key Insight:**
**"Plain English without magic numbers"** is mostly achieved through the export variables in templates (already very designer-friendly). The generator layer doesn't help with this - it adds abstraction without adding clarity for simple content.

**Recommendation:**
1. Keep Generator pattern for **Enemies** (complex generation justifies it)
2. Use Template pattern for **Abilities, Blessings, Rooms** (simple scaling)
3. Keep Direct Resources for **Unique Items** (curated content)
4. Add **ItemTemplate** for scaling handcrafted items by floor
5. Remove unused WeaponGenerator/ArmorGenerator if not planning procedural items

**The win:** Less code, clearer patterns, same designer-friendliness. Templates with good export hints are already "plain English" - you don't need generators for that.
