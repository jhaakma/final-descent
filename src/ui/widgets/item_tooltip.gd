class_name ItemTooltip

## Utility class for generating formatted tooltip text for items
##
## This class provides static methods to generate tooltip text for items,
## displaying relevant information based on item type (weapons, potions, etc.).

## Generate detailed tooltip text for an item
static func get_item_tooltip_text(item: Item, count: int = 1) -> String:
    if not item:
        return ""

    var tooltip_parts: Array[String] = []

    # Item name and type
    if count > 1:
        tooltip_parts.append("%s x%d" % [item.name, count])
    else:
        tooltip_parts.append("%s" % item.name)

    # Add item type information
    if item is Weapon:
        tooltip_parts.append("Type: Weapon")
    elif item is ItemPotion:
        tooltip_parts.append("Type: Potion")
    else:
        tooltip_parts.append("Type: Item")

    # Add description
    var description := item.get_description()
    if description and description != "":
        tooltip_parts.append("\n%s" % description)

    # Add weapon-specific stats
    if item is Weapon:
        var weapon := item as Weapon
        tooltip_parts.append("\nDamage: %d" % weapon.damage)

        # Show if currently equipped
        if GameState.player.equipped_weapon == weapon:
            tooltip_parts.append("★ Currently Equipped")

    # Add potion-specific information
    if item is ItemPotion:
        var potion := item as ItemPotion
        if potion.status_effect:
            tooltip_parts.append("\nEffect:")
            tooltip_parts.append(potion.status_effect.get_description())

    # Add value information
    tooltip_parts.append("\nValue: %d gold" % item.purchase_value)
    if item.get_consumable():
        tooltip_parts.append("Consumable")
    else:
        tooltip_parts.append("Reusable")

    return "\n".join(tooltip_parts)

## Generate simple tooltip text for an item (less detailed)
static func get_simple_item_tooltip_text(item: Item, count: int = 1) -> String:
    if not item:
        return ""

    var tooltip_parts: Array[String] = []

    # Item name
    if count > 1:
        tooltip_parts.append("%s x%d" % [item.name, count])
    else:
        tooltip_parts.append("%s" % item.name)

    # Basic description
    var description := item.get_description()
    if description != "":
        tooltip_parts.append(description)

    # Show damage for weapons
    if item is Weapon:
        var weapon := item as Weapon
        tooltip_parts.append("Damage: %d" % weapon.damage)

    return "\n".join(tooltip_parts)
