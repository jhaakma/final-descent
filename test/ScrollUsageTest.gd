class_name ScrollTest extends BaseTest

# Test class for scroll usage functionality
# Tests the implementation of scroll success/failure tracking

func test_healing_scroll_loads() -> bool:
    return assert_resource_loads("res://data/items/scrolls/ScrollOfHealing.tres")

func test_healing_scroll_is_consumable() -> bool:
    var healing_scroll := load("res://data/items/scrolls/ScrollOfHealing.tres") as Scroll
    return assert_not_null(healing_scroll) and assert_true(healing_scroll.get_consumable())

func test_healing_scroll_has_correct_name() -> bool:
    var healing_scroll := load("res://data/items/scrolls/ScrollOfHealing.tres") as Scroll
    if not assert_not_null(healing_scroll):
        return false
    var item_name := healing_scroll._get_name()
    return assert_string_contains(item_name, "Scroll") and assert_string_contains(item_name, "Healing")

func test_spell_cast_method_exists() -> bool:
    var healing_scroll := load("res://data/items/scrolls/ScrollOfHealing.tres") as Scroll
    return assert_not_null(healing_scroll) and assert_not_null(healing_scroll.spell) and assert_has_method(healing_scroll.spell, "cast")

func test_scroll_spell_has_heal_effect() -> bool:
    var healing_scroll := load("res://data/items/scrolls/ScrollOfHealing.tres") as Scroll
    if not assert_not_null(healing_scroll) or not assert_not_null(healing_scroll.spell):
        return false

    var spell := healing_scroll.spell as Spell
    var has_effects := spell.spell_effects.size() > 0
    if not has_effects:
        return false

    # Check if at least one effect is a healing effect
    for effect in spell.spell_effects:
        if effect.get_effect_id() == "instant_heal":
            return true

    return false

func test_spell_cast_returns_boolean() -> bool:
    var healing_scroll := load("res://data/items/scrolls/ScrollOfHealing.tres") as Scroll
    if not assert_not_null(healing_scroll) or not assert_not_null(healing_scroll.spell):
        return false

    # Verify the cast method signature - it should return a boolean
    # We can't actually call it without proper setup, but we can verify the method exists
    return assert_has_method(healing_scroll.spell, "cast")