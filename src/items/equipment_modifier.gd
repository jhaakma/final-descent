class_name EquipmentModifier extends Resource

## Resource defining a modifier that can be applied to equipment
## Modifiers add prefixes/suffixes to equipment names and enhance stats

@export var modifier_name: String = "Refined"
@export var name_prefix: String = "Refined"  # Added before item name
@export var name_suffix: String = ""  # Added after item name (leave empty for prefix-only)

## Stat modifiers (multipliers applied to base stats)
@export var damage_modifier: float = 1.0  # For weapons
@export var defense_modifier: float = 1.0  # For armor
@export var condition_modifier: float = 1.0  # For durability

## Restrictions - determines which items can use this modifier
@export var allowed_item_types: Array[Equippable.EquipSlot] = []  # Empty = all types allowed
@export var allowed_damage_types: Array[DamageType.Type] = []  # Empty = all damage types allowed (weapons only)
@export var forbidden_item_types: Array[Equippable.EquipSlot] = []  # These slots cannot use this modifier

## Check if this modifier can be applied to a specific weapon
func can_apply_to_weapon(weapon: Weapon) -> bool:
    # Check if weapon slot is forbidden
    if Equippable.EquipSlot.WEAPON in forbidden_item_types:
        return false

    # If allowed_item_types is specified and weapon is not in it, reject
    if not allowed_item_types.is_empty() and Equippable.EquipSlot.WEAPON not in allowed_item_types:
        return false

    # Check damage type restrictions if specified
    if not allowed_damage_types.is_empty() and weapon.damage_type not in allowed_damage_types:
        return false

    return true

## Check if this modifier can be applied to a specific armor piece
func can_apply_to_armor(armor: Armor) -> bool:
    # Check if armor slot is forbidden
    if armor.armor_slot in forbidden_item_types:
        return false

    # If allowed_item_types is specified and this armor slot is not in it, reject
    if not allowed_item_types.is_empty() and armor.armor_slot not in allowed_item_types:
        return false

    return true

## Check if this modifier can be applied to any equippable item
func can_apply_to(equippable: Equippable) -> bool:
    if equippable is Weapon:
        return can_apply_to_weapon(equippable as Weapon)
    elif equippable is Armor:
        return can_apply_to_armor(equippable as Armor)
    return false

## Get the modified name for an item
func get_modified_name(base_name: String) -> String:
    if name_prefix != "" and name_suffix != "":
        return "%s %s %s" % [name_prefix, base_name, name_suffix]
    elif name_prefix != "":
        return "%s %s" % [name_prefix, base_name]
    elif name_suffix != "":
        return "%s %s" % [base_name, name_suffix]
    return base_name

## Get description of what this modifier does
func get_description() -> String:
    var parts: Array[String] = []

    if damage_modifier != 1.0:
        var percent: int = roundi((damage_modifier - 1.0) * 100)
        parts.append("%+d%% Damage" % percent)

    if defense_modifier != 1.0:
        var percent: int = roundi((defense_modifier - 1.0) * 100)
        parts.append("%+d%% Defense" % percent)

    if condition_modifier != 1.0:
        var percent: int = roundi((condition_modifier - 1.0) * 100)
        parts.append("%+d%% Durability" % percent)

    if parts.is_empty():
        return "No stat changes"

    return ", ".join(parts)